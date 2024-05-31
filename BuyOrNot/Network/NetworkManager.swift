//
//  NetworkManager.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//


import Foundation
import Alamofire
import RxSwift
import RxCocoa
import Kingfisher

struct NetworkManager {

	//KingFisher 사용시 활용
	static let imageDownloadRequest = AnyModifier { request in
		var requestBody = request
		requestBody.setValue(UserDefaultsManager.accessToken,
//			UserDefaults.standard.string(forKey: UserDefaultsKey.accessToken.key) ?? "",
							 forHTTPHeaderField: HTTPHeader.authorization.rawValue)
		requestBody.setValue(APIKey.sesacKey.rawValue, forHTTPHeaderField: HTTPHeader.sesacKey.rawValue)

		return requestBody
	}

	static func performRequest<T: Decodable>(route: Router, decodingType: T.Type?) -> Single<T> {

		return Single<T>.create { single in
			do {
				let urlRequest = try route.asURLRequest()

				switch route {
				case .uploadImage(let query):
					guard let image = query as? ImagePostQuery else { return Disposables.create() }
					AF.upload(multipartFormData: { multipartFormData in
						multipartFormData.append(image.file,
												 withName: "files",
												 fileName: "buyOrNot.jpg",
												 mimeType: "image/jpg")
					}, with: urlRequest)
					.validate(statusCode: 200..<300)
					.responseDecodable(of: T.self) { response in
						switch response.result {
						case .success(let result):
							single(.success(result))
						case .failure(let error):
							single(.failure(error))
						}
					}
				case .editProfile(let query):
					guard let editData = query as? ProfileQuery else { return Disposables.create() }

					AF.upload(multipartFormData: { multipartFormData in

						if let data = editData.file {
							print("업로드되나요")
							multipartFormData.append(data, withName: "profile", fileName: "buyOrNot.jpg", mimeType: "image/jpg")
						}
						if let nick = editData.nick.data(using: .utf8) {
							multipartFormData.append(nick, withName: "nick")
						}
					}, with: urlRequest)
					.validate(statusCode: 200..<300)
					.responseDecodable(of: T.self) { response in
						switch response.result {
						case .success(let result):
							print("하ㅓ잉")
							single(.success(result))
						case .failure(let error):
							print(error)
							single(.failure(error))
						}
					}
				default:
					AF.request(urlRequest)
						.validate(statusCode: 200..<300)
						.responseDecodable(of: T.self) { response in
							print(response.request?.url)

							switch response.result {
							case .success(let result):
								print("success")
								single(.success(result))
								print(response.response?.statusCode)
							case .failure(let error):
								print("fail")
								print(response.response?.statusCode)
								single(.failure(error))

							}
						}
				}
			} catch {
				single(.failure(error))
			}

			return Disposables.create()
		}
		.retry(when: { errors in
			errors.flatMap { error -> Single<Void> in
				guard let afError = error as? AFError, afError.responseCode == 419 else {
					throw error
				}
				return refreshToken().flatMap { _ in
					performRequest(route: route, decodingType: T.self).map { _ in
						Void()
					}
				}
			}
		})
	}

	//응답값 없을때
	static func performRequestVoidType(route: Router) -> Single<Void> {
		return Single<Void>.create { single in
			do {
				let urlRequest = try route.asURLRequest()

				AF.request(urlRequest)
					.validate(statusCode: 200..<300)
					.response { response in
						switch response.result {
						case .success:
							print("Request succeeded with status code: \(String(describing: response.response?.statusCode))")
							single(.success(()))
						case .failure(let error):
							print("Request failed with error: \(error.localizedDescription) and status code: \(String(describing: response.response?.statusCode))")
							single(.failure(error))
						}
					}
			} catch {
				single(.failure(error))
			}

			return Disposables.create()
		}
		.retry(when: { errors in
			errors.flatMap { error -> Single<Void> in
				guard let afError = error as? AFError, afError.responseCode == 419 else {
					throw error
				}
				return refreshToken().flatMap { _ in
					performRequestVoidType(route: route).map { Void() }
				}
			}
		})
	}


	static func refreshToken() -> Single<Void> {
		return Single<Void>.create { single in
			let urlRequest = Router.tokenRefresh
			AF.request(urlRequest)
				.validate()
				.responseDecodable(of: AccessTokenModel.self) { response in
					switch response.result {
					case .success(let accessTokenModel):
						print("엑세스 토큰 갱신하자")
						UserDefaultsManager.accessToken = accessTokenModel.accessToken
//						UserDefaults.standard.set(accessTokenModel.accessToken, forKey: UserDefaultsKey.accessToken.key)
						single(.success(()))
					case .failure(let error):
						print("흠")
						print(response.response?.statusCode)
						// refreshToken이 실패할 경우엔 무조건 로그인 창으로
						NotificationCenter.default.post(name: .authenticationFailed, object: nil)
						single(.failure(error))
					}
				}
			return Disposables.create()
		}
	}
}

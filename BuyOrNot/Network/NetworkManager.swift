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

struct AccessTokenModel: Decodable {
	let accessToken: String
}

struct LoginModel: Decodable {
	let accessToken: String
	let refreshToken: String
}

struct MessageModel: Decodable {
	let message: String
}

struct JoinModel: Decodable {
	let user_id: String
	let email: String
	let nick: String
}

struct ImagePostModel: Decodable {
	let files: [String]
}

struct NetworkManager {

	static func createLogin(query: LoginQuery) -> Single<LoginModel> {
		return Single<LoginModel>.create { single in
			do {
				let urlRequest = try Router.login(query: query).asURLRequest()

				AF.request(urlRequest)
					.validate(statusCode: 200..<300)
					.responseDecodable(of: LoginModel.self) { response in
						switch response.result {
						case .success(let loginModel):
							single(.success(loginModel))
						case .failure(let error):
							single(.failure(error))
						}
					}

			} catch {
				single(.failure(error))
			}

			return Disposables.create()
		}
	}

	static func validateEmail(query: ValidationEmailQuery) -> Single<MessageModel> {
		return Single<MessageModel>.create { single in
			do {
				let urlRequest = try Router.validationEmail(query: query).asURLRequest()

				AF.request(urlRequest)
					.validate(statusCode: 200..<300)
					.responseDecodable(of: MessageModel.self) { response in
						switch response.result {
						case .success(let loginModel):
							single(.success(loginModel))
						case .failure(let error):
							single(.failure(error))
						}
					}
			} catch {
				single(.failure(error))
			}

			return Disposables.create()
		}
	}

	static func join(query: JoinQuery) -> Single<JoinModel> {
		return Single<JoinModel>.create { single in
			do {
				let urlRequest = try Router.join(query: query).asURLRequest()

				AF.request(urlRequest)
					.validate(statusCode: 200..<300)
					.responseDecodable(of: JoinModel.self) { response in
						switch response.result {
						case .success(let joinModel):
							single(.success(joinModel))
						case .failure(let error):
							single(.failure(error))
						}
					}
			} catch {
				single(.failure(error))
			}

			return Disposables.create()
		}
	}

//	static func postImage(query: ImagePostQuery) -> Single<ImagePostModel> {
//		return Single<ImagePostModel>.create { single in
//			do {
//				let urlRequest = try Router.imagePosts(query: query).asURLRequest()
//
//				AF.upload(multipartFormData: { multipartFormData in
//					multipartFormData.append(query.file,
//											 withName: "files",
//											 fileName: "buyOrNot.png",
//											 mimeType: "image/png")
//				}, with: urlRequest)
//				.validate(statusCode: 200..<300)
//				.responseDecodable(of: ImagePostModel.self) { response in
//					switch response.result {
//					case .success(let imagePostModel):
//						single(.success(imagePostModel))
//						print(imagePostModel.files)
//						print("Asdfasdfgjhidfghjaoighf")
//					case .failure(let error):
//						single(.failure(error))
//						print(response.response?.statusCode)
//					}
//				}
//
//			} catch {
//				single(.failure(error))
//			}
//
//
//			return Disposables.create()
//		}
//		.retry(when: { error in
//			error.flatMap { error -> Observable<Void> in
//				guard let afError = error as? AFError, afError.responseCode == 419 else { throw error }
//				return refreshToken().asObservable().map { _ in Void() }
//			}
//		})
//	}

	static func postImage(query: ImagePostQuery) -> Single<ImagePostModel> {
		return Single<ImagePostModel>.create { single in
			do {
				let urlRequest = try Router.imagePosts(query: query).asURLRequest()

				AF.upload(multipartFormData: { multipartFormData in
					multipartFormData.append(query.file,
											 withName: "files",
											 fileName: "buyOrNot.png",
											 mimeType: "image/png")
				}, with: urlRequest)
				.validate(statusCode: 200..<300)
				.responseDecodable(of: ImagePostModel.self) { response in
					switch response.result {
					case .success(let model):
						single(.success(model))
					case .failure(let error):
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
					postImage(query: query).map { _ in
						Void()
					}
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
						UserDefaults.standard.set(accessTokenModel.accessToken, forKey: UserDefaultsKey.accessToken.key)
						single(.success(()))
					case .failure(let error):
						print("흠")
						if let code = response.response?.statusCode, code == 418 {
							print("리프레시 토큰 만료")
							NotificationCenter.default.post(name: .authenticationFailed, object: nil)
						}
						single(.failure(error))
					}
				}
			return Disposables.create()
		}
	}
}


//	static func tokenRefresh(completionHandler: @escaping () -> Void) {
//		let url = URL(string: APIKey.baseURL.rawValue + "/v1/auth/refresh")!
//
//		let headers: HTTPHeaders = [
//			HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue,
//			HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: UserDefaultsKey.accessToken.key) ?? "",
//			HTTPHeader.refresh.rawValue: UserDefaults.standard.string(forKey: UserDefaultsKey.refreshToken.key) ?? ""
//		]
//
//		AF.request(url,
//				   method: .get,
//				   headers: headers)
//		.responseDecodable(of: accessTokenModel.self) { response in
//			switch response.result {
//
//			case .success(let success):
//				print("토근갱신성공")
//				UserDefaults.standard.setValue(success.accessToken, forKey: UserDefaultsKey.accessToken.key)
//				completionHandler()
//
//			case .failure(let failure):
//				if let code = response.response?.statusCode {
//					print("asdf")
//
//				} else {
//					print("토큰 갱신 실패")
//				}
//			}
//		}
//	}



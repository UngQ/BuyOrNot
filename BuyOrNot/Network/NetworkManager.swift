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

struct AccessTokenModel: Decodable {
	let accessToken: String
}



struct MessageModel: Decodable {
	let message: String
}

struct JoinModel: Decodable {
	let user_id: String
	let email: String
	let nick: String
}

struct ImageModel: Decodable {
	let files: [String]
}
struct PostModel: Decodable {
	let post_id: String
	let product_id: String
	let title: String?
	let content: String?
	let content1: String?
	let createdAt: String
	let creator: CreatorModel
	let files: [String]
	var likes: [String]
	var likes2: [String]
	let hashTags: [String]
	let comments: [CommentModel]
}

struct CommentModel: Decodable {
	let comment_id: String
	let content: String
	let createdAt: String
	let creator: CreatorModel
}

struct CreatorModel: Decodable {
	let user_id: String
	let nick: String
	let profileImage: String?
}

struct PostsModel: Decodable {
	let data: [PostModel]
	let next_cursor: String
}

struct NetworkManager {

	//KingFisher 사용시 활용
	static let imageDownloadRequest = AnyModifier { request in
		var requestBody = request
		requestBody.setValue(UserDefaults.standard.string(forKey: UserDefaultsKey.accessToken.key) ?? "", forHTTPHeaderField: HTTPHeader.authorization.rawValue)
		requestBody.setValue(APIKey.sesacKey.rawValue, forHTTPHeaderField: HTTPHeader.sesacKey.rawValue)

		return requestBody
	}

	static func performRequest<T: Decodable>(route: Router, decodingType: T.Type) -> Single<T> {
		return Single<T>.create { single in
			do {
				let urlRequest = try route.asURLRequest()

				if case Router.uploadImage(let query) = route {
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
				} else {
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

	static func createLogin(query: LoginQuery) -> Single<LoginModel> {
		return Single<LoginModel>.create { single in
			do {
				let urlRequest = try Router.login(query: query).asURLRequest()
				print(urlRequest.httpBody)
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


	static func uploadPost(query: PostQuery) -> Single<PostModel> {
		return Single<PostModel>.create { single in
			do {
				let urlRequest = try Router.uploadPost(query: query).asURLRequest()

				AF.request(urlRequest)
					.validate(statusCode: 200..<300)
					.responseDecodable(of: PostModel.self) { response in
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
	static func uploadImage(query: ImagePostQuery) -> Single<ImageModel> {
		return Single<ImageModel>.create { single in
			do {
				let urlRequest = try Router.uploadImage(query: query).asURLRequest()

				AF.upload(multipartFormData: { multipartFormData in
					multipartFormData.append(query.file,
											 withName: "files",
											 fileName: "buyOrNot.jpg",
											 mimeType: "image/jpg")
				}, with: urlRequest)
				.validate(statusCode: 200..<300)
				.responseDecodable(of: ImageModel.self) { response in
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
					uploadImage(query: query).map { _ in
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
						print(response.response?.statusCode)
						if let code = response.response?.statusCode, code == 418 {
							print("리프레시 토큰 만료")
							NotificationCenter.default.post(name: .authenticationFailed, object: nil)
						} else {
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



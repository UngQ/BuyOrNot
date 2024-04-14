//
//  NetworkManager.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import Foundation
import Alamofire
import RxSwift

struct LoginModel: Decodable {
	let accessToken: String
	let refreshToken: String
}

struct MessageModel: Decodable {
	let message: String
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



}





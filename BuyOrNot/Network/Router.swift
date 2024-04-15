//
//  Router.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import Foundation
import Alamofire

enum Router {
	case tokenRefresh

	case login(query: LoginQuery)
	case validationEmail(query: ValidationEmailQuery)
	case join(query: JoinQuery)

	case imagePosts(query: ImagePostQuery)
//    case withdraw
//    case fetchPost
//    case uploadPost

}

extension Router: TargetType {

	var baseURL: String {
		return APIKey.baseURL.rawValue
	}

	var method: Alamofire.HTTPMethod {
		switch self {
		case .tokenRefresh:
			return .get

		case .login,
			 .validationEmail,
			 .join,
			 .imagePosts:
			return .post

		}
	}

	var path: String {
		switch self {
		case .tokenRefresh:
			return "/v1/auth/refresh"
		case .login:
			return "/v1/users/login"
		case .validationEmail:
			return "/v1/validation/email"
		case .join:
			return "/v1/users/join"
		case .imagePosts:
			return "/v1/posts/files"
		}
	}

	var header: [String : String] {
		switch self {
		case.tokenRefresh:
			return [		
				HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue,
				HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: UserDefaultsKey.accessToken.key) ?? "",
				HTTPHeader.refresh.rawValue: UserDefaults.standard.string(forKey: UserDefaultsKey.refreshToken.key) ?? ""
			]

		case .login,
			 .validationEmail,
			 .join:
			return [
				HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
				HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue
			]
		case .imagePosts:
			return [HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: UserDefaultsKey.accessToken.key) ?? "",
					HTTPHeader.contentType.rawValue: HTTPHeader.multipart.rawValue,
					HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]

		}
	}

	var parameters: String? {
		return nil
	}

	var queryItems: [URLQueryItem]? {
		return nil
	}

	var body: Data? {
		switch self {
		case .tokenRefresh:
			return nil
		case .login(let query):
			let encoder = JSONEncoder()
			return try? encoder.encode(query)
		case .validationEmail(let query):
			let encoder = JSONEncoder()
			return try? encoder.encode(query)
		case .join(let query):
			let encoder = JSONEncoder()
			return try? encoder.encode(query)
		case .imagePosts(let query):
			return nil
		}
	}


}







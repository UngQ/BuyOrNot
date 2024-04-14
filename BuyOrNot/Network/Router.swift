//
//  Router.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import Foundation
import Alamofire

enum Router {
	case login(query: LoginQuery)
	case validationEmail(query: ValidationEmailQuery)
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
		case .login:
			return .post
		case .validationEmail:
			return .post
		}
	}

	var path: String {
		switch self {
		case .login:
			return "/v1/users/login"
		case .validationEmail:
			return "/v1/validation/email"
		}
	}

	var header: [String : String] {
		switch self {
		case .login,
			 .validationEmail:
			return [
				HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
				HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue
			]

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
		case .login(let query):
			let encoder = JSONEncoder()
			return try? encoder.encode(query)
		case .validationEmail(let query):
			let encoder = JSONEncoder()
			return try? encoder.encode(query)
		}
	}


}







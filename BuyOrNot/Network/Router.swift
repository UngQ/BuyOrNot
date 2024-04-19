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

	case login(query: Encodable)
	case validationEmail(query: Encodable)
	case join(query: Encodable)

	case uploadImage(query: Encodable)
	case uploadPost(query: Encodable)

	case lookPosts(query: PostQueryItems)

	case likePost(id: String, query: Encodable)
}

extension Router: TargetType {

	var baseURL: String {
		return APIKey.baseURL.rawValue
	}

	var method: Alamofire.HTTPMethod {
		switch self {
		case .tokenRefresh,
				.lookPosts:
			return .get

		case .login,
			 .validationEmail,
			 .join,
			 .uploadImage,
			 .uploadPost,
			 .likePost:
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
		case .uploadImage:
			return "/v1/posts/files"
		case .uploadPost,
				.lookPosts:
			return "/v1/posts"
		case .likePost(let id, _):
			return "/v1/posts/\(id)/like"
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
			
		case .uploadImage:
			return [HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: UserDefaultsKey.accessToken.key) ?? "",
					HTTPHeader.contentType.rawValue: HTTPHeader.multipart.rawValue,
					HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]

			case .uploadPost,
				.likePost:
			return [HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: UserDefaultsKey.accessToken.key) ?? "",
					HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
					HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]

		case .lookPosts:
			return [
				HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: UserDefaultsKey.accessToken.key) ?? "",
				HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]

		}
	}

	var parameters: String? {
		return nil
	}

	var queryItems: [URLQueryItem]? {
		switch self {
		case .lookPosts(let query):
				return [
					URLQueryItem(name: "next", value: query.next),
					URLQueryItem(name: "limit", value: query.limit),
					URLQueryItem(name: "product_id", value: query.product_id)
				]
		default:
			return nil
		}
	}

	var body: Data? {
		switch self {
		case .tokenRefresh,
				.uploadImage,
				.lookPosts:
			return nil
		case .login(let query),
			.validationEmail(let query),
			.join(let query),
			.uploadPost(let query),
			.likePost(_, let query):
			let encoder = JSONEncoder()
			return try? encoder.encode(query)

		}
	}
}

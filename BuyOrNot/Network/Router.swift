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
	case uploadComment(id: String, query: Encodable)

	case lookPosts(query: PostQueryItems)
	case lookPost(id: String)
	case hashTag(query: PostQueryItems)

	case likePost(id: String, query: Encodable, like: String)

	case userPost(query: PostQueryItems, id: String)
}

extension Router: TargetType {

	var baseURL: String {
		return APIKey.baseURL.rawValue
	}

	var method: Alamofire.HTTPMethod {
		switch self {
		case .tokenRefresh,
				.lookPosts,
				.lookPost,
				.hashTag,
				.userPost:
			return .get

		case .login,
			 .validationEmail,
			 .join,
			 .uploadImage,
			 .uploadPost,
			 .uploadComment,
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
		case .uploadComment(let id, _):
			return "/v1/posts/\(id)/comments"
		case .lookPost(let id):
			return "/v1/posts/\(id)"
		case .likePost(let id, _, let like):
			return "/v1/posts/\(id)/\(like)"
		case .hashTag:
			return "/v1/posts/hashtags"
		case .userPost(_, let id):
			return "/v1/posts/users/\(id)"
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
				.likePost,
				.uploadComment:
			return [HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: UserDefaultsKey.accessToken.key) ?? "",
					HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
					HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]

		case .lookPosts,
				.lookPost,
			.hashTag,
			.userPost:
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
		case .lookPosts(let query),
				.userPost(let query, _):
				return [
					URLQueryItem(name: "next", value: query.next),
					URLQueryItem(name: "limit", value: query.limit),
					URLQueryItem(name: "product_id", value: query.product_id)
				]

		case .hashTag(let query):
			return [
				URLQueryItem(name: "next", value: query.next),
				URLQueryItem(name: "limit", value: query.limit),
				URLQueryItem(name: "product_id", value: query.product_id),
				URLQueryItem(name: "hashTag", value: query.hashTag)
			]

		default:
			return nil
		}
	}

	var body: Data? {
		switch self {
		case .tokenRefresh,
				.uploadImage,
				.lookPosts,
				.hashTag,
				.lookPost,
				.userPost:
			return nil
		case .login(let query),
			.validationEmail(let query),
			.join(let query),
			.uploadPost(let query),
			.likePost(_, let query, _),
			.uploadComment(_, let query):
			let encoder = JSONEncoder()
			return try? encoder.encode(query)

		}
	}
}

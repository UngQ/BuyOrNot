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

	case deleteComment(id: String, commentId: String)
	case updateComment(id: String, commentId: String, query: Encodable)

	case lookPosts(query: PostQueryItems)
	case lookPost(id: String)
	case hashTag(query: PostQueryItems)

	case likePost(id: String, query: Encodable, like: String)

	case userPost(query: PostQueryItems, id: String)

	case myProfile
	case myLikes(query: PostQueryItems)
	case myDislikes(query: PostQueryItems)


	case othersProfile(id: String)
	
	case plusFollow(id: String)
	case deleteFollow(id: String)

	case deletePost(id: String)
	case editProfile(query: Encodable)

	case validationPayment(query: Encodable)

	case withdraw
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
				.userPost,
				.myProfile,
				.myLikes,
				.myDislikes,
				.othersProfile,
				.withdraw:
			return .get

		case .login,
			 .validationEmail,
			 .join,
			 .uploadImage,
			 .uploadPost,
			 .uploadComment,
			 .likePost,
			 .plusFollow,
			 .validationPayment:
			return .post

		case .updateComment,
				.editProfile:
			return .put

		case .deleteComment,
				.deleteFollow,
				.deletePost:

			return .delete
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
		
		case .lookPost(let id),
			 .deletePost(let id):
			return "/v1/posts/\(id)"

		case .likePost(let id, _, let like):
			return "/v1/posts/\(id)/\(like)"
		
		case .hashTag:
			return "/v1/posts/hashtags"
		
		case .userPost(_, let id):
			return "/v1/posts/users/\(id)"
		
		case .deleteComment(let id, let commentId),
			 .updateComment(let id, let commentId, _):
			return "/v1/posts/\(id)/comments/\(commentId)"

		case .myProfile,
			 .editProfile:
			return "/v1/users/me/profile"
		
		case .myLikes:
			return "/v1/posts/likes/me"
		
		case .myDislikes:
			return "/v1/posts/likes-2/me"
		
		case .othersProfile(let id):
			return "/v1/users/\(id)/profile"
		
		case .plusFollow(let id),
				.deleteFollow(let id):
			return "/v1/follow/\(id)"

		case .validationPayment:
			return "/v1/payments/validation"

		case .withdraw:
			return "/v1/users/withdraw"


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
			
		case .uploadImage,
			 .editProfile:
			return [HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: UserDefaultsKey.accessToken.key) ?? "",
					HTTPHeader.contentType.rawValue: HTTPHeader.multipart.rawValue,
					HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]

			case .uploadPost,
				.likePost,
				.uploadComment,
				.updateComment,
				.validationPayment:
			return [HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: UserDefaultsKey.accessToken.key) ?? "",
					HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
					HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]

		case .lookPosts,
				.lookPost,
			.hashTag,
			.userPost,
			.deleteComment,
			.myProfile,
			.myLikes,
			.myDislikes,
			.othersProfile,
			.plusFollow,
			.deleteFollow,
			.deletePost,
			.withdraw
			:
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
				.userPost(let query, _),
				.myLikes(let query),
				.myDislikes(let query)
				:
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
				.userPost,
				.deleteComment,
				.myProfile,
				.myLikes,
				.myDislikes,
				.othersProfile,
				.plusFollow,
				.deleteFollow,
				.deletePost,
				.editProfile,
				.withdraw

				:
			return nil
		case .login(let query),
			.validationEmail(let query),
			.join(let query),
			.uploadPost(let query),
			.likePost(_, let query, _),
			.uploadComment(_, let query),
			.updateComment(_, _, let query),
			.validationPayment(let query):
			let encoder = JSONEncoder()
			return try? encoder.encode(query)

		}
	}
}

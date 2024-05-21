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
	case paymentList

	case naverPhoto(query: String, start: Int, display: String)

	//chat
	case myChats
	case makeChat(query: Encodable)
	case lookChat(id: String)
	case sendChat(id: String, query: Encodable)

}

extension Router: TargetType {

	var baseURL: String {
		switch self {
		case .naverPhoto:
			return APIKey.naverPhotoURL.rawValue
		default:
			return APIKey.baseURL.rawValue
		}
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
				.withdraw,
				.paymentList,
				.naverPhoto,
				.myChats,
				.lookChat:
			return .get

		case .login,
			 .validationEmail,
			 .join,
			 .uploadImage,
			 .uploadPost,
			 .uploadComment,
			 .likePost,
			 .plusFollow,
			 .validationPayment,
			 .makeChat,
			 .sendChat:
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

		case .paymentList:
			return "/v1/payments/me"

		case .naverPhoto:
			return "/v1/search/image"

		case .myChats,
				.makeChat:
			return "/v1/chats"

		case .lookChat(let id), .sendChat(let id, _):
			return "/v1/chats/\(id)"

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
				.validationPayment,
				.makeChat,
				.sendChat:
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
			.withdraw,
			.paymentList,
			.myChats,
			.lookChat
			:
			return [
				HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: UserDefaultsKey.accessToken.key) ?? "",
				HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]

		case .naverPhoto:
			return ["X-Naver-Client-Id": APIKey.naverClientID.rawValue,
					"X-Naver-Client-Secret": APIKey.naverClientSecret.rawValue]

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
				.myDislikes(let query):
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
		case .naverPhoto(let query, let start, let display):
			return [
				URLQueryItem(name: "query", value: query),
				URLQueryItem(name: "start", value: "\(start)"),
				URLQueryItem(name: "display", value: display)
			]

		default:
			return nil
		}
	}

	var body: Data? {
		switch self {
		case .login(let query),
				.validationEmail(let query),
				.join(let query),
				.uploadPost(let query),
				.likePost(_, let query, _),
				.uploadComment(_, let query),
				.updateComment(_, _, let query),
				.validationPayment(let query),
				.makeChat(let query),
				.sendChat(_, let query):
			let encoder = JSONEncoder()
			return try? encoder.encode(query)

		default:
			return nil
		}
	}
}

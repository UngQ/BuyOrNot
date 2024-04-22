//
//  NetworkModel.swift
//  BuyOrNot
//
//  Created by ungQ on 4/16/24.
//

import Foundation

struct LoginModel: Decodable {
	let user_id: String
	let email: String
	let nick: String
	let profileImage: String?
	let accessToken: String
	let refreshToken: String
}

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
	let title: String
	let content: String
	let content1: String
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

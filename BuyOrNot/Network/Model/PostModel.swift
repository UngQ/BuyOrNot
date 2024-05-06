//
//  PostModel.swift
//  BuyOrNot
//
//  Created by ungQ on 5/5/24.
//

import Foundation

struct PostModel: Decodable, Equatable {
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
	let buyers: [String]

	static func == (lhs: PostModel, rhs: PostModel) -> Bool {
		return lhs.post_id == rhs.post_id
	 }
}

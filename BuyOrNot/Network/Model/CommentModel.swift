//
//  CommentModel.swift
//  BuyOrNot
//
//  Created by ungQ on 5/5/24.
//

import Foundation

struct CommentModel: Decodable, Equatable {
	let comment_id: String
	let content: String
	let createdAt: String
	let creator: CreatorModel

	static func == (lhs: CommentModel, rhs: CommentModel) -> Bool {
		 return lhs.comment_id == rhs.comment_id
	 }
}

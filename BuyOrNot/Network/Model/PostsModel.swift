//
//  PostsModel.swift
//  BuyOrNot
//
//  Created by ungQ on 5/5/24.
//

import Foundation

struct PostsModel: Decodable, Equatable {
	let data: [PostModel]
	let next_cursor: String

	static func == (lhs: PostsModel, rhs: PostsModel) -> Bool {
		return lhs.data == rhs.data
	 }
}

//
//  CreatorModel.swift
//  BuyOrNot
//
//  Created by ungQ on 5/5/24.
//

import Foundation

struct CreatorModel: Decodable, Equatable {
	let user_id: String
	let nick: String
	let profileImage: String?

	static func == (lhs: CreatorModel, rhs: CreatorModel) -> Bool {
		 return lhs.user_id == rhs.user_id
	 }
}

//
//  FollowModel.swift
//  BuyOrNot
//
//  Created by ungQ on 5/5/24.
//

import Foundation

struct FollowModel: Decodable {
	let nick: String
	let opponent_nick: String
	let following_status: Bool
}

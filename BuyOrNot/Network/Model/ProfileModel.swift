//
//  ProfileModel.swift
//  BuyOrNot
//
//  Created by ungQ on 5/5/24.
//

import Foundation

struct ProfileModel: Decodable {
	let user_id: String
	let nick: String
	let profileImage: String?
	var followers: [CreatorModel]
	var following: [CreatorModel]
	let posts: [String]
}

//
//  LoginModel.swift
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

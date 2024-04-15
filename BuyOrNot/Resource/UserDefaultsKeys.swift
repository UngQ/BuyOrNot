//
//  UserDefaultsKeys.swift
//  BuyOrNot
//
//  Created by ungQ on 4/15/24.
//

import Foundation

enum UserDefaultsKey: String {
	case email
	case password
	case accessToken
	case refreshToken

	var key: String {
		return self.rawValue
	}
}

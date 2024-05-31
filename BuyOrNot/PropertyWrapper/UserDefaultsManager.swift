//
//  UserDefaultsManager.swift
//  BuyOrNot
//
//  Created by ungQ on 5/31/24.
//

import Foundation

@propertyWrapper
struct MyDefaults<T> {
	let key: String
	let defaultValue: T

	var wrappedValue: T {
		get {
			UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
		}
		set {
			UserDefaults.standard.setValue(newValue, forKey: key)
		}
	}
}

enum UserDefaultsManager {

	enum Key: String {
		case userId
		case email
		case password
		case accessToken
		case refreshToken
		case nick
		case profileImage
//		case autoLogin
		case autoLoginEnabled
	}

	@MyDefaults(key: Key.userId.rawValue, defaultValue: "")
	static var userId: String

	@MyDefaults(key: Key.email.rawValue, defaultValue: "이메일 없음")
	static var email: String

	@MyDefaults(key: Key.password.rawValue, defaultValue: "")
	static var password: String

	@MyDefaults(key: Key.accessToken.rawValue, defaultValue: "")
	static var accessToken: String

	@MyDefaults(key: Key.refreshToken.rawValue, defaultValue: "")
	static var refreshToken: String

	@MyDefaults(key: Key.nick.rawValue, defaultValue: "닉네임 없음")
	static var nick: String

	@MyDefaults(key: Key.profileImage.rawValue, defaultValue: "")
	static var profileImage: String

//	@MyDefaults(key: Key.autoLogin.rawValue, defaultValue: false)
//	static var autoLogin: Bool

	@MyDefaults(key: Key.autoLoginEnabled.rawValue, defaultValue: false)
	static var autoLoginEnabled: Bool

}

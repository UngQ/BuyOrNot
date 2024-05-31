//
//  ChatListModel.swift
//  BuyOrNot
//
//  Created by ungQ on 5/17/24.
//

import Foundation
import ExyteChat

struct ChatListModel: Decodable, Equatable {
	let data: [ChatModel]

	static func == (lhs: ChatListModel, rhs: ChatListModel) -> Bool {
		return lhs.data == rhs.data
	 }
}

struct ChatModel: Decodable, Equatable {

	let room_id: String
	let createdAt: String
	let updatedAt: String
	let participants: [CreatorModel]
	let lastChat: ChatContentModel?

	static func == (lhs: ChatModel, rhs: ChatModel) -> Bool {
		return lhs.room_id == rhs.room_id
	 }
}

struct ChatContentModel: Decodable, Equatable {
	let chat_id: String
	let room_id: String
	let content: String?
	let createdAt: String
	let sender: CreatorModel
	let files: [String]

	static func == (lhs: ChatContentModel, rhs: ChatContentModel) -> Bool {
		return lhs.chat_id == rhs.chat_id
	 }

	var toMessage: Message {

		let myId = UserDefaultsManager.userId
//		UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""
		var myChat: Bool = sender.user_id == myId

		let isoDateFormatter = ISO8601DateFormatter()
		isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

		return Message(id: chat_id,
					   user: User(id: sender.user_id,
								  name: sender.nick,
								  avatarURL: URL(string: "https://github.com/UngQ/ungQ/assets/106305918/9e33e9b4-1aa0-4d07-be83-ad6a90ba2c46"),
								  isCurrentUser: myChat),
					   createdAt: isoDateFormatter.date(from: createdAt) ?? Date(),
					   text: content ?? "")

	}
}



struct ChatRoomModel: Decodable, Equatable {

	var data: [ChatContentModel]

	static func == (lhs: ChatRoomModel, rhs: ChatRoomModel) -> Bool {
		return lhs.data == rhs.data
	 }
}


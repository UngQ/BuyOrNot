//
//  ChatListModel.swift
//  BuyOrNot
//
//  Created by ungQ on 5/17/24.
//

import Foundation

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

struct ChatContentModel: Decodable {
	let chat_id: String
	let room_id: String
	let content: String?
	let createdAt: String
	let sender: CreatorModel
	let files: [String]
}



struct ChatRoomModel: Decodable {

	var data: [ChatContentModel]

}


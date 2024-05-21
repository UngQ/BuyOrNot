//
//  ChatRoomViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 5/19/24.
//

import Foundation
import Combine

final class ChatRoomViewModel: ObservableObject {

	var cancellable = Set<AnyCancellable>()
	var chatId: String

	@Published
	var messages: [ChatContentModel] = []

	init(chatId: String) {

		self.chatId = chatId


		SocketIOManager.shared?.receivedChatData
			.sink { [weak self] chat in
				self?.messages.append(chat)
			}
			.store(in: &cancellable)

	}

}

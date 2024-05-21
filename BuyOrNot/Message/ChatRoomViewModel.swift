//
//  ChatRoomViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 5/19/24.
//

import Foundation
import Combine
import RxSwift
import ExyteChat

final class ChatRoomViewModel: ObservableObject {


	var cancellable = Set<AnyCancellable>()
	var disposeBag = DisposeBag()
	var chatId: String

	@Published
	var messages: [Message] = []

	init(chatId: String) {

		self.chatId = chatId

		NetworkManager.performRequest(route: .lookChat(id: chatId), decodingType: ChatRoomModel.self)
			.map { result in
				result.data.map { $0.toMessage }
			}
			.subscribe(with: self) { owner, messages in
				self.messages = messages
			}
			.disposed(by: disposeBag)

		SocketIOManager.shared?.receivedChatData
			.sink { [weak self] chat in
				self?.messages.append(chat.toMessage)
			}
			.store(in: &cancellable)

	}

	func sendMessage(message: String) {
		NetworkManager.performRequest(route: .sendChat(id: chatId, query: MessageQuery(content: message)), decodingType: ChatContentModel.self)
			.subscribe(with: self) { owner, result in
				print("성공")
			}
			.disposed(by: disposeBag)
	}

}

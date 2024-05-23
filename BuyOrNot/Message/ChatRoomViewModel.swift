//
//  ChatRoomViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 5/19/24.
//

import SwiftUI
import Combine
import RxSwift
import ExyteChat

final class ChatRoomViewModel: ObservableObject {


	var cancellable = Set<AnyCancellable>()
	var disposeBag = DisposeBag()
	var chatId: String
	var nick: String

	@Published
	var messages: [Message] = []


	init(chatId: String, nick: String) {

		self.chatId = chatId
		self.nick = nick

		NetworkManager.performRequest(route: .lookChat(id: chatId), decodingType: ChatRoomModel.self)
			.map { result in
				result.data.map { $0.toMessage }
			}
			.subscribe(with: self) { owner, messages in
//				self.messages = []
				self.messages = messages
			}
			.disposed(by: disposeBag)

		SocketIOManager.shared.receivedChatData
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

//	func sendImageMessage(image: UIImage) {
//		// Here you would upload the image to your server and get the URL
//		// For example purposes, we will use a placeholder URL
//		let imageURL = "https://example.com/uploaded_image.jpg"
//
//		// Create a new message with the image URL
//		let newMessage = Message(content: imageURL, type: .)
//		Message(id: <#T##String#>, user: <#T##User#>, status: <#T##Message.Status?#>, createdAt: <#T##Date#>, text: <#T##String#>, attachments: [Attachment(id: "", url: URL(string: ""), type: .image)], recording: <#T##Recording?#>, replyMessage: <#T##ReplyMessage?#>)
//
//		// Append the new message to the messages array
//		messages.append(newMessage)
//	}

}

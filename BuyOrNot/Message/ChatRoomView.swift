//
//  ChatRoomView.swift
//  BuyOrNot
//
//  Created by ungQ on 5/19/24.
//

import SwiftUI
import RxSwift
import Combine
import ExyteChat
import IQKeyboardManagerSwift

struct ChatRoomView: View {

	@StateObject var viewModel: ChatRoomViewModel
	@State private var newMessage = ""

    var body: some View {


		VStack {



//			ScrollViewReader { proxy in
//				List(viewModel.messages.data, id: \.chat_id) { chat in
//
//					ChatRowView(chat: chat)
//						.id(chat.chat_id)
//						.listRowSeparator(.hidden)
//				}
//				.listStyle(.plain)
//				.onChange(of: viewModel.messages.data) { _ in
//					scrollToBottom(proxy: proxy)
//				}
//
//			}

			// Exyte Chat List View
			ChatView(messages: $viewModel.messages.wrappedValue) { _ in

			} inputViewBuilder: { textBinding, attachments, state, style, actionClosure, dismissKeyboardClosure in
				EmptyView()
				
			}
			.avatarSize(avatarSize: 0)




			HStack {
				TextField("메세지를 입력해주세요.", text: $newMessage, axis: .vertical)
					.lineLimit(3)

				Button(action: sendMessage, label: {
					Image(systemName: "paperplane")
				})
			}
			.padding()

		}
		.padding()
		.navigationTitle("Direct Message 💬")

		.task {
			SocketIOManager.shared?.establishConnection()
			IQKeyboardManager.shared.enable = false
		}
		.onDisappear {
			SocketIOManager.shared?.leaveConnection()
			IQKeyboardManager.shared.enable = true
		}
	}

//	private func scrollToBottom(proxy: ScrollViewProxy) {
//		if let lastMessage = viewModel.messages.data.last {
//			
//			proxy.scrollTo(lastMessage.chat_id, anchor: .bottom)
//
//		 }
//	 }

	private func sendMessage() {

		if !newMessage.isEmpty {

			print("전송")
			viewModel.sendMessage(message: newMessage)
			newMessage = ""
		}

	}

	
}

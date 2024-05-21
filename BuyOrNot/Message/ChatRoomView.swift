//
//  ChatRoomView.swift
//  BuyOrNot
//
//  Created by ungQ on 5/19/24.
//

import SwiftUI
import RxSwift

struct ChatRoomView: View {

	@StateObject var viewModel: ChatRoomViewModel
	@State private var newMessage = ""

    var body: some View {


		VStack {



			ScrollViewReader { proxy in
			
				List(viewModel.messages.data, id: \.chat_id) { chat in
					ChatRowView(chat: chat)
						.id(chat.chat_id)
						.listRowSeparator(.hidden)
				}
				.listStyle(.plain)
				.onChange(of: viewModel.messages.data) { _ in
					scrollToBottom(proxy: proxy)
				}

			}

			HStack {
				TextField("내용을 입력해주세요", text: $newMessage, axis: .vertical)
					.lineLimit(3)
				Button(action: sendMessage, label: {
					Image(systemName: "paperplane")
				})
			}
			.padding()
		}
		.navigationTitle("Direct Message")
		.task {
			SocketIOManager.shared?.establishConnection()
		}
		.onDisappear {
			SocketIOManager.shared?.leaveConnection()
		}
	}

	private func scrollToBottom(proxy: ScrollViewProxy) {
		if let lastMessage = viewModel.messages.data.last {
			
			proxy.scrollTo(lastMessage.chat_id, anchor: .bottom)

		 }
	 }

	private func sendMessage() {

		if !newMessage.isEmpty {

			print("전송")
			viewModel.sendMessage(message: newMessage)
			newMessage = ""
		}

	}
}

//#Preview {
//    ChatRoomView(viewModel: <#T##ChatRoomViewModel#>)
//}

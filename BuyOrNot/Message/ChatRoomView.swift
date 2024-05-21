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

			List(viewModel.messages.data, id: \.chat_id) { chat in
				ChatRowView(chat: chat)

			}

			HStack {
				TextField("내용을 입력해주세요", text: $newMessage, axis: .vertical)
					.lineLimit(3)
				Button(action: sendMessage, label: {
					Image(systemName: "paperplane")
				})
			}
			.padding()

			Button("소켓 해제") {
				SocketIOManager.shared?.leaveConnection()
			}

		}
		.task {
			
			SocketIOManager.shared?.establishConnection()
		}
	}

	func sendMessage() {

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

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

			// Exyte Chat List View
			ChatView(messages: $viewModel.messages.wrappedValue) { _ in

			} inputViewBuilder: { textBinding, attachments, state, style, actionClosure, dismissKeyboardClosure in
				EmptyView()
				
			}


			.avatarSize(avatarSize: 36)
			.padding(.trailing, 6)




			HStack {
				TextField("메세지를 입력해주세요.", text: $newMessage, axis: .vertical)
					.lineLimit(3)

				Button(action: sendMessage) {
					Image(systemName: "paperplane")
						.frame(width: 30, height: 30)

				}



			}
			.padding(.horizontal)
			.padding(.bottom)

		}

		.navigationTitle("\(viewModel.nick)님 💬")

		.task {
			print("어피얼")
			SocketIOManager.shared.establishConnection()
			IQKeyboardManager.shared.enable = false
			IQKeyboardManager.shared.resignOnTouchOutside = true
		}

		.onDisappear {
			SocketIOManager.shared.leaveConnection()
			IQKeyboardManager.shared.enable = true
			print("디싸피얼")

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

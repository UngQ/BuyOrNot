//
//  ChatRoomView.swift
//  BuyOrNot
//
//  Created by ungQ on 5/19/24.
//

import SwiftUI

struct ChatRoomView: View {

	@StateObject var viewModel: ChatRoomViewModel

    var body: some View {


		VStack {

			List(viewModel.messages, id: \.chat_id) { chat in
				Text(chat.content)
					.padding()
					.background(.gray.opacity(0.5))
			}
			Button("소켓 해제") {
				SocketIOManager.shared?.leaveConnection()
			}

		}
		.task {
			SocketIOManager.shared?.establishConnection()
		}
	}
}

//#Preview {
//    ChatRoomView(viewModel: <#T##ChatRoomViewModel#>)
//}

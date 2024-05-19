//
//  ChatRoomView.swift
//  BuyOrNot
//
//  Created by ungQ on 5/19/24.
//

import SwiftUI

struct ChatRoomView: View {
    var body: some View {
		VStack {

			List(viewModel.messages, id: \.self) { chat in
				Text(chat.content)
					.padding()
					.background(Color.gray.opacity(0.5))
			}
			Button("소켓 해제") {
				SocketIOManager.shared.leaveConnection()
			}

		}
		.task {
			SocketIOManager.shared.establishConnection()
		}
	}
}

#Preview {
    ChatRoomView()
}

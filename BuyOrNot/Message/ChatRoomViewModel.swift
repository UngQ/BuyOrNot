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

	@Published
	var messages: [RealChat] = []

	init() {

//		SocketIOManager.shared.receivedChatData
//			.sink { chat in
//				self.messages.append(chat)
//			}
//			.store(in: &cancellable)

	}

}

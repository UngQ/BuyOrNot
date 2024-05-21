//
//  SocketIOManager.swift
//  BuyOrNot
//
//  Created by ungQ on 5/21/24.
//

import Foundation
import SocketIO
import Combine


final class SocketIOManager {

	static var shared: SocketIOManager?

	var manager: SocketManager!
	var socket: SocketIOClient!

	let baseURL = URL(string: "\(APIKey.baseURL.rawValue)/v1")!
	var roomId: String
	lazy var socketURL = "/chats-\(roomId)"

	var receivedChatData = PassthroughSubject<ChatContentModel, Never>()

	
	private init(roomId: String) {
		self.roomId = roomId
		print("SOCKETIOMANAGER INIT")
		manager = SocketManager(socketURL: baseURL, config: [.log(true), .compress])

		socket = manager.socket(forNamespace: socketURL)

		socket.on(clientEvent: .connect) { data, ack in
			print("socket connected", data, ack)
		}

		socket.on(clientEvent: .disconnect) { data, ack in
			print("socket disconnected", data, ack)
		}


		//[Any] > Data > Struct
		socket.on("chat") { dataArray, ack in
			print("chat received", dataArray, ack )

			if let data = dataArray.first {
				//나중엔 do catch 문으로 바꾸삼
				let result = try? JSONSerialization.data(withJSONObject: data)

				let decodedData = try? JSONDecoder().decode(ChatContentModel.self, from: result!)

				self.receivedChatData.send(decodedData!)


			}



		}
	}

	func establishConnection() {
		socket.connect()
	}

	func leaveConnection() {
		socket.disconnect()
	}

	static func initializeSharedInstance(roomId: String) {
		shared = SocketIOManager(roomId: roomId)
	}

}

//
//  ChatRowView.swift
//  BuyOrNot
//
//  Created by ungQ on 5/19/24.
//

import SwiftUI

struct ChatRowView: View {

	var chat: ChatContentModel
	let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""
	var myChat: Bool {
		chat.sender.user_id == myId
	}

	var body: some View {
		HStack(spacing: 10) {
//			Spacer()

			if myChat {
				Spacer()
			} else {
				Image(systemName: "person.circle.fill")
					.resizable()
					.frame(width: 30, height: 30)

			}



			Text(chat.content ?? "")
				.padding()
				.foregroundStyle(myChat ? .white : .black)
				.background(myChat ? .blue : .gray.opacity(0.5))
				
				.clipShape(.capsule)
		}

		.frame(maxWidth: .infinity, alignment: .leading)
	}
}


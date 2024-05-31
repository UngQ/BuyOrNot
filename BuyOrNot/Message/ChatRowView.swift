//
//  ChatRowView.swift
//  BuyOrNot
//
//  Created by ungQ on 5/19/24.
//

import SwiftUI

struct ChatRowView: View {

	var chat: ChatContentModel
	let myId = UserDefaultsManager.userId
//	UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""
	var myChat: Bool {
		chat.sender.user_id == myId
	}

	var body: some View {
		VStack {
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
					.cornerRadius(10)


			}
			.frame(maxWidth: .infinity, alignment: .leading)

			HStack{
				if myChat {
					Spacer()
					Text(chat.createdAt.formattedDate())
						.font(.caption)
					
				} else {
					Text(chat.createdAt.formattedDate())
						.font(.caption)
					Spacer()
					
				}
			}

		}

	}
}


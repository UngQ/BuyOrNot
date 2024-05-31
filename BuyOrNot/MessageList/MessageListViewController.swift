//
//  MessageListViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 5/17/24.
//

import UIKit
import SwiftUI

class MessageListViewController: BaseViewController {

	let viewModel = MessageListViewModel()

	let listTableView = UITableView(frame: .zero, style: .plain)

	let emptyLabel = {
		let view = UILabel()
		view.text = "대화내역이 없습니다."
		view.font = .boldSystemFont(ofSize: 16)
		view.textAlignment = .center
		return view
	}()



	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationItem.title = "1:1 채팅방"

		view.addSubview(listTableView)

		listTableView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}

		listTableView.register(MessageListTableViewCell.self, forCellReuseIdentifier: MessageListTableViewCell.id)
//		listTableView.rowHeight = 60


		view.addSubview(emptyLabel)
		view.addSubview(loadingLottieView)

		emptyLabel.snp.makeConstraints { make in
			make.centerY.centerX.equalToSuperview()
		}

		loadingLottieView.isHidden = false
		loadingLottieView.play()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		viewModel.viewWillAppearTrigger.accept(())
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		viewModel.viewWillDisappearTrigger.accept(())
	}

	override func bind() {

		let input = MessageListViewModel.Input()

		let output = viewModel.transform(input: input)

		output.data.map({ $0.data })
			.drive(with: self) { owner, data in
				if data == [] {
					owner.emptyLabel.isHidden = false
				} else {
					owner.emptyLabel.isHidden = true
				}
				owner.loadingLottieView.isHidden = true
				owner.loadingLottieView.stop()
			}
			.disposed(by: disposeBag)


		output.data
			.map { $0.data }
			.drive(listTableView.rx.items(cellIdentifier: MessageListTableViewCell.id, cellType: MessageListTableViewCell.self)) { row, element, cell  in


				let myId = UserDefaultsManager.userId
//				UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""

				var otherUserId: String?
				var otherUserNick: String?
				var otherUserProfileImage: String?
				for participant in element.participants {
					if participant.user_id != myId {
						otherUserId = participant.user_id
						otherUserNick = participant.nick
						otherUserProfileImage = participant.profileImage
						break
					}
				}

				if let endPoint = otherUserProfileImage {
					let profileImage = "\(APIKey.baseURL.rawValue)/v1/\(endPoint)"
					cell.profileImageView.loadImage(from: profileImage)
				}

				cell.nicknameLabel.text = otherUserNick
				cell.commentLabel.text = element.lastChat?.content
				cell.dateLabel.text = element.updatedAt.formattedDate()

				cell.nicknameLabel.rx.tapGesture()
					.when(.recognized)
					.bind(with: self) { owner, gesture in
						owner.pushOtherUserProfile(otherUserId: otherUserId)
					}
					.disposed(by: cell.disposeBag)

				cell.profileImageView.rx.tapGesture()
					.when(.recognized)
					.bind(with: self) { owner, gesture in
						owner.pushOtherUserProfile(otherUserId: otherUserId)
					}
					.disposed(by: cell.disposeBag)




			}
			.disposed(by: disposeBag)

		listTableView.rx.itemSelected
			.asDriver()
			.drive(with: self) { owner, indexPath in

				let myId = UserDefaultsManager.userId
//				UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""


				let data = owner.viewModel.chatListData.value.data[indexPath.row]
				let roomId = data.room_id

				var nick: String?
				for participant in data.participants {
					if participant.user_id != myId {
						nick = participant.nick
						break
					}
				}
				owner.tabBarController?.tabBar.isHidden = true
				SocketIOManager.shared.fetchSocket(roomId: roomId)
//				SocketIOManager.initializeSharedInstance(roomId: roomId)
				let chatRoomView = ChatRoomView(viewModel: ChatRoomViewModel(chatId: roomId, nick: nick ?? ""))

				let hostingController = UIHostingController(rootView: chatRoomView)

				owner.navigationController?.pushViewController(hostingController, animated: true)

			}
			.disposed(by: disposeBag)


	}

	private func pushOtherUserProfile(otherUserId: String?) {

		let vc = ProfileViewController()
		vc.viewModel.myOrOther = false
		vc.viewModel.othersId = otherUserId ?? ""
		vc.tabmanVC.myOrOthers = false
		vc.tabmanVC.myPostsVC.viewModel.myId = otherUserId ?? ""
		self.navigationController?.pushViewController(vc, animated: true)
	}

}

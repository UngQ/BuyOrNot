//
//  MessageListViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 5/17/24.
//

import UIKit

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

		view.addSubview(listTableView)

		listTableView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}

		listTableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.id)
		listTableView.rowHeight = 60

		viewModel.viewDidLoadTrigger.accept(())

		view.addSubview(emptyLabel)

		emptyLabel.snp.makeConstraints { make in
			make.centerY.centerX.equalToSuperview()
		}
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
			}
			.disposed(by: disposeBag)


		output.data
			.map { $0.data }
			.drive(listTableView.rx.items(cellIdentifier: CommentTableViewCell.id, cellType: CommentTableViewCell.self)) { row, element, cell  in


				let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""

				var otherUserNick: String?
				   for participant in element.participants {
					   if participant.user_id != myId {
						   otherUserNick = participant.nick
						   break
					   }
				   }




				cell.nicknameLabel.text = otherUserNick
				cell.commentLabel.text = element.lastChat?.content


				let vc = ProfileViewController()

//				if myOrOther {
//					self.navigationController?.pushViewController(vc, animated: true)
//				} else {
//					vc.viewModel.myOrOther = false
//					vc.viewModel.othersId = id
//					vc.tabmanVC.myOrOthers = false
//					vc.tabmanVC.myPostsVC.viewModel.myId = id
//					self.navigationController?.pushViewController(vc, animated: true)
//				}


			}
			.disposed(by: disposeBag)

		listTableView.rx.itemSelected
			.asDriver()
			.drive(with: self) { owner, indexPath in
				

			}
			.disposed(by: disposeBag)


	}

}

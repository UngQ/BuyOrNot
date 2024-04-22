//
//  CommentViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/22/24.
//

import UIKit
import RxSwift
import RxCocoa

class CommentViewController: BaseViewController {

	let viewModel = CommentViewModel()

	let commentTableView = {
		let view = UITableView()
		view.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.id)
		return view
	}()

	let commentTextField = UITextField()
	let sendButton = PointButton(title: "↑")

	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationItem.title = "댓글"

//		presentHalfModal()

	
		setupConstraints()
	}

	override func bind() {

		var isValidation = false

		let input = CommentViewModel.Input(commentText: commentTextField.rx.text.orEmpty,
										   sendButtonTap: sendButton.rx.tap)
		

		let output = viewModel.transform(input: input)

		output.isValidation
			.drive(with: self) { owner, validation in
				print(validation)
				owner.sendButton.isEnabled = validation
				owner.sendButton.backgroundColor = validation ? .systemBlue : .lightGray
			}
			.disposed(by: disposeBag)


		input.sendButtonTap.asDriver()
			.drive(with: self) { owner, _ in
				owner.commentTextField.text = ""
				owner.view.endEditing(true)
			}
			.disposed(by: disposeBag)


		output.data
			.drive(commentTableView.rx.items(cellIdentifier: CommentTableViewCell.id, cellType: CommentTableViewCell.self)) { row, element, cell in
				cell.selectionStyle = .none

				cell.nicknameLabel.text = element.creator.nick
				cell.commentLabel.text = element.content


				let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""
				if myId == element.creator.user_id {
					cell.deleteButton.isHidden = false
					cell.editButton.isHidden = false
				} else {
					cell.deleteButton.isHidden = true
					cell.editButton.isHidden = true
				}

			}
			.disposed(by: disposeBag)


	}

	override func configureLayout() {
		view.addSubview(commentTableView)
		view.addSubview(commentTextField)
		view.addSubview(sendButton)

		commentTextField.borderStyle = .roundedRect
		commentTextField.placeholder = "댓글을 입력해보세요."

		sendButton.isEnabled = false

	}

	private func presentHalfModal() {
		if let sheetPresentationController = sheetPresentationController {
			sheetPresentationController.detents = [.medium(), .large()]
			sheetPresentationController.prefersGrabberVisible = true
		}
	}


	func setupConstraints() {


		commentTableView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide)
			make.left.right.equalTo(view)
			make.bottom.equalTo(commentTextField.snp.top).offset(-10)
		}

		commentTextField.snp.makeConstraints { make in
			make.left.equalTo(view.snp.left).offset(10)
			make.right.equalTo(sendButton.snp.left).offset(-10)
			make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
		}

		sendButton.snp.makeConstraints { make in
			make.right.equalTo(view.snp.right).offset(-10)
			make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
			make.height.equalTo(commentTextField.snp.height)
			make.width.equalTo(50)
		}
	}

}

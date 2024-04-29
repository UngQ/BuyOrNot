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
	let emptyLabel = {
		let view = UILabel()
		view.text = "아직 작성된 댓글이 없습니다."
		view.font = .boldSystemFont(ofSize: 24)
		view.textAlignment = .center
		return view
	}()

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.viewModel.viewWillAppearTrigger.accept(())
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationItem.title = "댓글"

//		presentHalfModal()

	
		setupConstraints()
	}

	override func bind() {
		let editButtonTapped = PublishSubject<Int>()
		let deleteButtonTapped = PublishSubject<Int>()



		let input = CommentViewModel.Input(commentText: commentTextField.rx.text.orEmpty,
										   sendButtonTap: sendButton.rx.tap,
										   editButtonTap: editButtonTapped.asObservable(),
										   deleteButtonTap: deleteButtonTapped.asObservable())


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
			.drive(with: self) { owner, comments in
				if comments == [] {
					owner.emptyLabel.isHidden = false
				} else {
					owner.emptyLabel.isHidden = true
				}
			}
			.disposed(by: disposeBag)

		output.data
			.drive(commentTableView.rx.items(cellIdentifier: CommentTableViewCell.id, cellType: CommentTableViewCell.self)) { row, element, cell in
				cell.selectionStyle = .none
				

				
				
				cell.nicknameLabel.text = element.creator.nick
				cell.commentLabel.text = element.content
				cell.dateLabel.text = element.createdAt.formattedDate()
				if let endPoint = element.creator.profileImage {
					let profileImage = "\(APIKey.baseURL.rawValue)/v1/\(endPoint)"
					cell.profileImageView.loadImage(from: profileImage)
				} 
				cell.editButton.rx.tap
					.map { row }
					.bind(to: editButtonTapped)
					.disposed(by: cell.disposeBag)
				cell.deleteButton.rx.tap
					.map { row }
					.bind(to: deleteButtonTapped)
					.disposed(by: cell.disposeBag)

				cell.editButton.rx.tap
					.asDriver()
					.drive(with: self) { owner, _ in
						print("여러번대나")
						owner.navigationController?.pushViewController(EditCommentViewController(), animated: true)
					}
					.disposed(by: cell.disposeBag)


				let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""
				if myId == element.creator.user_id {
					cell.deleteButton.isHidden = false
					cell.editButton.isHidden = false
				} else {
					cell.deleteButton.isHidden = true
					cell.editButton.isHidden = true
				}

				cell.profileImageView.rx.tapGesture()
					.when(.recognized)
					.bind(with: self) { owner, gesture in
						let vc = ProfileViewController()

						if element.creator.user_id == myId {

							owner.navigationController?.pushViewController(vc, animated: true)
						} else {
							vc.viewModel.myOrOther = false
							vc.viewModel.othersId = element.creator.user_id
							vc.tabmanVC.myOrOthers = false
							vc.tabmanVC.myPostsVC.viewModel.myId = element.creator.user_id
							owner.navigationController?.pushViewController(vc, animated: true)
						}
					}
					.disposed(by: cell.disposeBag)

				cell.nicknameLabel.rx.tapGesture()
					.when(.recognized)
					.bind(with: self) { owner, gesture in
						let vc = ProfileViewController()

						if element.creator.user_id == myId {
							owner.navigationController?.pushViewController(vc, animated: true)
						} else {
							vc.viewModel.myOrOther = false
							vc.viewModel.othersId = element.creator.user_id
							vc.tabmanVC.myOrOthers = false
							vc.tabmanVC.myPostsVC.viewModel.myId = element.creator.user_id
							owner.navigationController?.pushViewController(vc, animated: true)
						}
					}
					.disposed(by: cell.disposeBag)
			}
			.disposed(by: disposeBag)

		output.deletedMessage
			.drive(with: self) { owner, message in
				owner.view.makeToast(message, position: .center)
			}
			.disposed(by: disposeBag)

		

	}

	override func configureLayout() {
		view.addSubview(commentTableView)
		view.addSubview(commentTextField)
		view.addSubview(sendButton)
		view.addSubview(emptyLabel)

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
		emptyLabel.snp.makeConstraints { make in
			make.centerY.centerX.equalToSuperview()
		}

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



//
//  CommentViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/22/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import IQKeyboardManagerSwift

protocol CommentViewControllerDelegate: AnyObject {
	func pushOthersProfile(myOrOther: Bool, id: String)
}


final class CommentViewController: BaseViewController {

	let viewModel = CommentViewModel()
	weak var commentVCDelegate: CommentViewControllerDelegate?


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

	private var textFieldBottomConstraint: Constraint?
	private var buttonBottomConstraint: Constraint?

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.viewModel.viewWillAppearTrigger.accept(())
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationItem.title = "댓글"

		setupConstraints()

		IQKeyboardManager.shared.disabledDistanceHandlingClasses = [CommentViewController.self]
		registerKeyboardNotification()

	}

	func registerKeyboardNotification()
	{
		// 키보드 표시 노티피케이션 등록
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
											   name: UIResponder.keyboardWillShowNotification,
											   object: nil)
		// 키보드 사라짐 노티피케이션 등록
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
											   name: UIResponder.keyboardWillHideNotification,
											   object: nil)
	 }


	@objc func keyboardWillShow(_ notification: Notification) {
		if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom

			UIView.animate(withDuration: 0.3) {
				self.textFieldBottomConstraint?.update(inset: keyboardHeight + 10)
				self.buttonBottomConstraint?.update(inset: keyboardHeight + 10)
				self.commentTableView.snp.updateConstraints { make in
					make.bottom.equalTo(self.commentTextField.snp.top).offset(-10)
				}
				self.view.layoutIfNeeded()
			}
		}
	}

	@objc func keyboardWillHide(_ notification: Notification) {
		UIView.animate(withDuration: 0.3) {
			self.textFieldBottomConstraint?.update(inset: 10)
			self.buttonBottomConstraint?.update(inset: 10)
			self.commentTableView.snp.updateConstraints { make in
				make.bottom.equalTo(self.commentTextField.snp.top).offset(-10)
			}
			self.view.layoutIfNeeded()
		}
	}



	override func bind() {
		let editButtonTapped = PublishSubject<Int>()
		let deleteButtonTapped = PublishSubject<Int>()
		let confirmDeleteTapped = PublishSubject<Int>()



		let input = CommentViewModel.Input(commentText: commentTextField.rx.text.orEmpty,
										   sendButtonTap: sendButton.rx.tap,
										   editButtonTap: editButtonTapped.asObservable(),
										   deleteButtonTap: confirmDeleteTapped.asObservable())


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
					.subscribe(with: self) { owner, _ in
						owner.showDeletionAlert(for: row, deleteSubject: confirmDeleteTapped) {
							confirmDeleteTapped.onNext(row)
						}
					}
					.disposed(by: cell.disposeBag)

				cell.editButton.rx.tap
					.asDriver()
					.drive(with: self) { owner, _ in


						let vc = EditCommentViewController()
						vc.viewModel.postId = owner.viewModel.postID
						vc.viewModel.commentId = element.comment_id
						vc.commentTextField.text = element.content
						

						owner.navigationController?.pushViewController(vc, animated: true)
					}
					.disposed(by: cell.disposeBag)


				let myId = UserDefaultsManager.userId
//				UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""
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
//						let vc = ProfileViewController()

						if element.creator.user_id == myId {

							owner.commentVCDelegate?.pushOthersProfile(myOrOther: true, id: myId)
							owner.dismiss(animated: true)
		
						} else {

							owner.commentVCDelegate?.pushOthersProfile(myOrOther: false, id: element.creator.user_id)
							owner.dismiss(animated: true)

						}
					}
					.disposed(by: cell.disposeBag)

				cell.nicknameLabel.rx.tapGesture()
					.when(.recognized)
					.bind(with: self) { owner, gesture in
//						let vc = ProfileViewController()

						if element.creator.user_id == myId {
							owner.commentVCDelegate?.pushOthersProfile(myOrOther: true, id: myId)
							owner.dismiss(animated: true)
						} else {
							owner.commentVCDelegate?.pushOthersProfile(myOrOther: false, id: element.creator.user_id)
							owner.dismiss(animated: true)
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

	func setupConstraints() {

		emptyLabel.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
			make.centerX.equalTo(view)
		}

		commentTableView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
			make.left.right.equalTo(view)
			make.bottom.equalTo(commentTextField.snp.top).offset(-10)
		}

		commentTextField.snp.makeConstraints { make in
			make.left.equalTo(view.snp.left).offset(10)
			make.right.equalTo(sendButton.snp.left).offset(-10)
			textFieldBottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10).constraint
		}

		sendButton.snp.makeConstraints { make in
			make.right.equalTo(view.snp.right).offset(-10)
			make.height.equalTo(commentTextField.snp.height)
			make.width.equalTo(50)
			buttonBottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10).constraint
		}
	}



}



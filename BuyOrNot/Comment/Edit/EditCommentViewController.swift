//
//  EditCommentViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/23/24.
//

import UIKit


final class EditCommentViewController: BaseViewController {


	let viewModel = EditCommentViewModel()

	let commentTextField: UITextView = {
		let textView = UITextView()

		textView.text = ""
		textView.font = .systemFont(ofSize: 14)
		textView.layer.cornerRadius = 12
		textView.layer.borderColor = UIColor.black.cgColor
		textView.layer.borderWidth = 1
		return textView
	}()

	var completedButton = UIButton()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white


		completedButton.setTitle("수정", for: .normal)
		completedButton.backgroundColor = .systemBlue
		completedButton.layer.cornerRadius = 15
		completedButton.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
		completedButton.tintColor = .textPoint
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: completedButton)



	}

	override func bind() {

	

		let input = EditCommentViewModel.Input(commentText: commentTextField.rx.text.orEmpty,
											   completedButtonTapped: completedButton.rx.tap)

		

		let output = viewModel.transform(input: input)

		output.completedMessage
			.drive(with: self) { owner, message in
				owner.view.makeToast(message, position: .center)
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
					owner.navigationController?.popViewController(animated: true)
				}
			}
			.disposed(by: disposeBag)
	}


	override func configureLayout() {
		view.addSubview(commentTextField)



		commentTextField.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
			make.left.right.equalTo(view).inset(20)
			make.height.equalTo(view.bounds.height/4)
	}

	}

}

//
//  EditCommentViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/23/24.
//

import UIKit

class EditCommentViewController: UIViewController {

	// Text field for editing a comment
	let commentTextField: UITextView = {
		let textView = UITextView()

		textView.text = "asdf"
		textView.font = .systemFont(ofSize: 14)
		textView.layer.cornerRadius = 12
		textView.layer.borderColor = UIColor.black.cgColor
		textView.layer.borderWidth = 1
		return textView
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupLayout()

		let menuButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: nil)
		self.navigationItem.rightBarButtonItem = menuButton

	}

	private func setupLayout() {
		// Add subviews
		view.addSubview(commentTextField)


		// Set constraints using SnapKit
		commentTextField.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
			make.left.right.equalTo(view).inset(20)
			make.height.equalTo(view.bounds.height/4)


		}
	}

}

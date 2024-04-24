//
//  NicknameViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import UIKit

class NicknameViewController: BaseViewController {


	let viewModel = NicknameViewModel()

	let nicknameTextField = SignTextField(placeholderText: "닉네임을 입력해주세요")
	let descriptionLabel = UILabel()
	let nextButton = PointButton(title: "가입하기")

	override func viewDidLoad() {
		super.viewDidLoad()

		configureLayout()

	}

	override func bind() {


		let input = NicknameViewModel.Input(nickname: nicknameTextField.rx.text.orEmpty,
											nextButtonTap: nextButton.rx.tap)

		let output = viewModel.transform(input: input)

		output.isValidation
			.drive(with: self) { owner, valid in
				owner.nextButton.isEnabled = valid
				owner.nextButton.backgroundColor = valid ? .systemBlue : .lightGray
			}
			.disposed(by: disposeBag)

		output.isCompleteJoin
			.drive(with: self) { owner, complete in
				print("Completed")
				
				NicknameViewController.changeRootView(to: CustomTabBarController(), isNav: true)
				
			}
			.disposed(by: disposeBag)


	}



	override func configureLayout() {
		view.addSubview(nicknameTextField)
		view.addSubview(descriptionLabel)
		view.addSubview(nextButton)

		nicknameTextField.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}

		descriptionLabel.snp.makeConstraints { make in
			make.height.equalTo(24)
			make.top.equalTo(nicknameTextField.snp.bottom).offset(5)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}

		nextButton.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(descriptionLabel.snp.bottom).offset(5)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}

		descriptionLabel.text = "3~10자, 공백, 자음, 모음 불가"
		descriptionLabel.font = .boldSystemFont(ofSize: 14)
		descriptionLabel.textColor = .systemRed


	}

}

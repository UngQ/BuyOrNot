//
//  PasswordViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import UIKit

class PasswordViewController: BaseViewController {

	let viewModel = PasswordViewModel()

	let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
	let confirmPasswordTextField = SignTextField(placeholderText: "다시 한번 입력해주세요")
	let nextButton = PointButton(title: "다음")
	let descriptionLabel = UILabel()
	let confirmDescriptionLabel = UILabel()

	override func viewDidLoad() {
		super.viewDidLoad()

		configureLayout()
		setNavigationTitleImage()
	}

	override func bind() {

		let input = PasswordViewModel.Input(passwordText: passwordTextField.rx.text.orEmpty,
											confirmPasswordText: confirmPasswordTextField.rx.text.orEmpty)

		let output = viewModel.transform(input: input)

		output.initValid
			.drive(with: self) { owner, valid in
				owner.passwordTextField.layer.borderColor = valid ? UIColor.systemBlue.cgColor : UIColor.systemRed.cgColor
				owner.descriptionLabel.isHidden = valid
				owner.confirmPasswordTextField.isEnabled = valid


			}
			.disposed(by: disposeBag)

		output.initValid
			.filter { $0 == true }
			.flatMapLatest { _ in output.finalValid }
			.drive(with: self) { owner, valid in
				owner.confirmPasswordTextField.layer.borderColor = valid ? UIColor.systemBlue.cgColor : UIColor.systemRed.cgColor
				owner.nextButton.backgroundColor = valid ? .systemBlue : .lightGray
				owner.nextButton.isEnabled = valid
				owner.confirmDescriptionLabel.isHidden = valid
			}
			.disposed(by: disposeBag)



		nextButton.rx.tap
			.withLatestFrom(input.confirmPasswordText)
			.asDriver(onErrorJustReturn: "")
			.drive(with: self) { owner, password in
				UserDefaults.standard.setValue(password, forKey: UserDefaultsKey.password.key)
				owner.navigationController?.pushViewController(NicknameViewController(), animated: true)
			}
			.disposed(by: disposeBag)


	}



	override func configureLayout() {
		view.addSubview(passwordTextField)
		view.addSubview(confirmPasswordTextField)
		view.addSubview(nextButton)
		view.addSubview(descriptionLabel)
		view.addSubview(confirmDescriptionLabel)

		passwordTextField.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}

		descriptionLabel.snp.makeConstraints { make in
			make.height.equalTo(24)
			make.top.equalTo(passwordTextField.snp.bottom).offset(5)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}

		confirmPasswordTextField.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(descriptionLabel.snp.bottom).offset(5)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}

		confirmDescriptionLabel.snp.makeConstraints { make in
			make.height.equalTo(24)
			make.top.equalTo(confirmPasswordTextField.snp.bottom).offset(5)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}

		nextButton.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(confirmDescriptionLabel.snp.bottom).offset(5)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}

		passwordTextField.isSecureTextEntry = true
		confirmPasswordTextField.isSecureTextEntry = true
		descriptionLabel.text = "8~16자 영문 대,소문자, 숫자, 특수문자를 사용하세요"
		descriptionLabel.numberOfLines = 0
		descriptionLabel.font = .boldSystemFont(ofSize: 14)
		descriptionLabel.textColor = .systemRed

		confirmDescriptionLabel.text = "비밀번호가 일치하지 않습니다."
		confirmDescriptionLabel.numberOfLines = 0
		confirmDescriptionLabel.font = .boldSystemFont(ofSize: 14)
		confirmDescriptionLabel.textColor = .systemRed
		confirmDescriptionLabel.isHidden = true

		nextButton.isEnabled = false
	}

}

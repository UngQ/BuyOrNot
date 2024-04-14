//
//  SignUpViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Toast

class SignUpViewController: BaseViewController {

	let viewModel = SignUpViewModel()

	let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
	let validationButton = {
		let button = UIButton()
		button.setTitle("중복 확인", for: .normal)
		button.setTitleColor(Color.black, for: .normal)
		button.layer.borderWidth = 1
		button.layer.borderColor = Color.black.cgColor
		button.layer.cornerRadius = 10
		return button
	}()
	let nextButton = PointButton(title: "다음")
	let buttonColor = Observable.just(UIColor.lightGray)

	override func viewDidLoad() {
		super.viewDidLoad()
		configureLayout()

		view.backgroundColor = Color.white

	}

	override func bind() {

		var isValidation = false

		let input = SignUpViewModel.Input(emailTextField: emailTextField.rx.text.orEmpty,
										  validationButtonTap: validationButton.rx.tap)

		let output = viewModel.transform(input: input)

		nextButton.rx.tap
			.bind(with: self) { owner, _ in
				if isValidation {
					UserDefaults.standard.setValue(owner.emailTextField.text, forKey: "email")
					owner.navigationController?.pushViewController(PasswordViewController(), animated: true)
				} else {
					self.view.makeToast("이메일 입력 후, 중복 확인 부탁드립니다.", position: .center)
				}
			}
			.disposed(by: disposeBag)

		output.validationMessage
			.drive(with: self) { owner, message in
				owner.view.makeToast(message, position: .center)
			}
			.disposed(by: disposeBag)

		output.isValidation
			.drive(with: self) { owner, validation in
//				owner.nextButton.isEnabled = validation
				isValidation = validation
				owner.nextButton.backgroundColor = validation ? .systemBlue : .lightGray
			}
			.disposed(by: disposeBag)

	}

	func configureLayout() {
		view.addSubview(emailTextField)
		view.addSubview(validationButton)
		view.addSubview(nextButton)


		validationButton.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
			make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
			make.width.equalTo(100)
		}

		emailTextField.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
			make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
			make.trailing.equalTo(validationButton.snp.leading).offset(-8)
		}

		nextButton.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(emailTextField.snp.bottom).offset(30)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}
	}

}

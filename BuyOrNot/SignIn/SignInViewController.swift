//
//  SignInViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SignInViewController: BaseViewController {

	let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
	let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
	let signInButton = PointButton(title: "로그인")
	let signUpButton = UIButton()

	private let viewModel = SignInViewModel()

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = Color.white

		configureLayout()
		configure()
	}

	override func bind() {
		signUpButton.rx.tap
			.asDriver()
			.drive(with: self) { owner, _ in
				owner.navigationController?.pushViewController(SignUpViewController(), animated: true)
			}
			.disposed(by: disposeBag)

		let input = SignInViewModel.Input(
			emailText: emailTextField.rx.text.orEmpty.asObservable(),
			passwordText: passwordTextField.rx.text.orEmpty.asObservable(),
			loginButtonTapped: signInButton.rx.tap.asObservable())

		let output = viewModel.transform(input: input)

		output.loginValidation
			.drive(with: self) { owner, valid in
				owner.signInButton.isEnabled = valid
			}
			.disposed(by: disposeBag)

		output.loginSuccessTrigger
			.drive(with: self) { owner, _ in
				owner.changeRootView(to: CategoryViewController(), isNav: true)
			}
			.disposed(by: disposeBag)

	}


	func configure() {
		signUpButton.setTitle("회원이 아니십니까?", for: .normal)
		signUpButton.setTitleColor(Color.black, for: .normal)
	}

	func configureLayout() {
		view.addSubview(emailTextField)
		view.addSubview(passwordTextField)
		view.addSubview(signInButton)
		view.addSubview(signUpButton)

		emailTextField.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}

		passwordTextField.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(emailTextField.snp.bottom).offset(30)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}

		signInButton.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(passwordTextField.snp.bottom).offset(30)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}

		signUpButton.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(signInButton.snp.bottom).offset(30)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}
	}


}

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
import Toast

final class SignInViewController: BaseViewController {

	let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
	let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
	let signInButton = PointButton(title: "로그인")
	let signUpButton = UIButton()

	private let viewModel = SignInViewModel()

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = Color.white

		setNavigationTitleImage()
		configureLayout()
		configure()
	}

	override func bind() {

		let input = SignInViewModel.Input(
			emailText: emailTextField.rx.text.orEmpty.asObservable(),
			passwordText: passwordTextField.rx.text.orEmpty.asObservable(),
			loginButtonTapped: signInButton.rx.tap.asObservable())

		let output = viewModel.transform(input: input)
//
//		output.loginValidation
//			.drive(with: self) { owner, valid in
//				owner.signInButton.isEnabled = valid
//			}
//			.disposed(by: disposeBag)

		output.loginSuccessTrigger
			.drive(with: self) { owner, _ in
				SignInViewController.changeRootView(to: CustomTabBarController(), isNav: true)
			}
			.disposed(by: disposeBag)

		output.errorMessage
			.drive(with: self) { owner, message in
				owner.view.makeToast(message, position: .center)
			}
			.disposed(by: disposeBag)

	}
	
	func configure() {
		signUpButton.setTitle("회원 가입", for: .normal)

		signUpButton.setAttributedTitle(NSAttributedString(string: "회원가입", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]), for: .normal)
		signUpButton.setTitleColor(Color.black, for: .normal)
	}

	override func configureLayout() {
		view.addSubview(emailTextField)
		view.addSubview(passwordTextField)
		view.addSubview(signInButton)
		view.addSubview(signUpButton)

		emailTextField.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
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
			make.height.equalTo(40)
			make.width.equalTo(80)
			make.top.equalTo(signInButton.snp.bottom).offset(4)
			make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
		}

		emailTextField.keyboardType = .emailAddress
		passwordTextField.isSecureTextEntry = true
	}


}

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

	let scrollView = UIScrollView()
	let contentView = UIView()
	let titleImageView = UIImageView(image: UIImage(named: "titleImage"))
	let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
	let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
	let signInButton = PointButton(title: "로그인")
	let signUpButton = UIButton()

	let autoLoginSwitch = UISwitch()
	let autoLoginLabel = UILabel()

	let viewModel = SignInViewModel()

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = Color.white


		configureLayout()
		configure()

		navigationController?.isNavigationBarHidden = true

		loadCredentialsAndLogin()


	}


	override func bind() {

		let input = SignInViewModel.Input(
			emailText: emailTextField.rx.text.orEmpty.asObservable(),
			passwordText: passwordTextField.rx.text.orEmpty.asObservable(),
			loginButtonTapped: signInButton.rx.tap.asObservable())

		let output = viewModel.transform(input: input)

		output.loginValidation
			.drive(with: self) { owner, valid in
				owner.signInButton.backgroundColor = valid ? .systemBlue : .lightGray
				owner.signInButton.isEnabled = valid
			}
			.disposed(by: disposeBag)

		output.loginSuccessTrigger
			.drive(with: self) { owner, _ in
				print("대는겨ㅇㅇㅇ??")
				owner.successLoginLottieView.isHidden = false
				owner.successLoginLottieView.play { completed in


					if owner.autoLoginSwitch.isOn {
						print("대는겨??")
						let email = owner.emailTextField.text ?? ""
						let password = owner.passwordTextField.text ?? ""
						owner.viewModel.handleAutoLogin(email, password: password, enable: true)

					}


						UIViewController.changeRootView(to: CustomTabBarController(), isNav: true)

				}
			}
			.disposed(by: disposeBag)

		output.errorMessage
			.drive(with: self) { owner, message in
				owner.view.makeToast(message, position: .center)
			}
			.disposed(by: disposeBag)

		signUpButton.rx.tap
			.asDriver()
			.drive(with: self) { owner, _ in
				owner.navigationController?.pushViewController(SignUpViewController(), animated: true)
			}
			.disposed(by: disposeBag)

	}
	
	func configure() {
		signUpButton.setTitle("회원 가입", for: .normal)

		signUpButton.setAttributedTitle(NSAttributedString(string: "회원가입", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]), for: .normal)
		signUpButton.setTitleColor(Color.black, for: .normal)

		autoLoginLabel.text = "자동 로그인"
		 autoLoginLabel.textColor = .darkGray
		 autoLoginLabel.font = UIFont.systemFont(ofSize: 14)
	}

	override func configureLayout() {


		view.addSubview(scrollView)
		scrollView.addSubview(contentView)
		contentView.addSubview(titleImageView)
		contentView.addSubview(emailTextField)
		contentView.addSubview(passwordTextField)
		contentView.addSubview(signInButton)
		contentView.addSubview(signUpButton)
		contentView.addSubview(autoLoginSwitch)
		contentView.addSubview(autoLoginLabel)
		view.addSubview(successLoginLottieView)

		successLoginLottieView.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.size.equalTo(100)
		}

		scrollView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}

		contentView.snp.makeConstraints { make in
			make.verticalEdges.equalTo(scrollView)
			make.width.equalTo(scrollView.snp.width)
			make.bottom.equalTo(signUpButton.snp.bottom)
		}

		titleImageView.snp.makeConstraints { make in
			make.height.equalTo(titleImageView.snp.width)
			make.top.equalTo(contentView.snp.top).offset(30)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(100)
		}


		emailTextField.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(titleImageView.snp.bottom).offset(30)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}

		passwordTextField.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(emailTextField.snp.bottom).offset(20)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}

		signInButton.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(passwordTextField.snp.bottom).offset(20)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}

		signUpButton.snp.makeConstraints { make in
			make.height.equalTo(40)
			make.width.equalTo(80)
			make.top.equalTo(signInButton.snp.bottom).offset(4)
			make.trailing.equalTo(view.safeAreaLayoutGuide).inset(6)
		}


		autoLoginSwitch.snp.makeConstraints { make in
			 make.top.equalTo(signInButton.snp.bottom).offset(10)
			 make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
		 }

		 autoLoginLabel.snp.makeConstraints { make in
			 make.centerY.equalTo(autoLoginSwitch)
			 make.leading.equalTo(autoLoginSwitch.snp.trailing).offset(10)
		 }

		scrollView.isScrollEnabled = true
		emailTextField.keyboardType = .emailAddress
		passwordTextField.isSecureTextEntry = true

	}

	func loadCredentialsAndLogin() {
		let credentials = viewModel.checkAutoLogin()
		if let email = credentials.email, let password = credentials.password {
			autoLoginSwitch.isOn = true
			emailTextField.text = email
			passwordTextField.text = password
			DispatchQueue.main.async {
				
				self.successLoginLottieView.isHidden = false
				self.successLoginLottieView.play()

				self.emailTextField.becomeFirstResponder()
				if let endPosition = self.emailTextField.position(from: self.emailTextField.endOfDocument, offset: 0) {
					self.emailTextField.selectedTextRange = self.emailTextField.textRange(from: endPosition, to: endPosition)
				}

				self.passwordTextField.becomeFirstResponder()
				if let endPosition = self.passwordTextField.position(from: self.passwordTextField.endOfDocument, offset: 0) {
					self.passwordTextField.selectedTextRange = self.passwordTextField.textRange(from: endPosition, to: endPosition)
				}

				self.signInButton.sendActions(for: .touchUpInside)
			}
		}
	}




}

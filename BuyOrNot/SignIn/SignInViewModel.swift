//
//  SignInViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import Foundation
import RxSwift
import RxCocoa
import KeychainSwift

final class SignInViewModel: ViewModelType {

	var disposeBag = DisposeBag()

	struct Input {
		let emailText: Observable<String>
		let passwordText: Observable<String>
		let loginButtonTapped: Observable<Void>
	}

	struct Output {
		let errorMessage: Driver<String>
		let loginValidation: Driver<Bool>
		let loginSuccessTrigger: Driver<Void>
	}

	func transform(input: Input) -> Output {

		let errorMessage = PublishRelay<String>()
		let loginValid = BehaviorRelay(value: false)
		let loginSuccessTrigger = PublishRelay<Void>()

		let loginObservable = Observable.combineLatest(
			input.emailText,
			input.passwordText
		)


		loginObservable
			.map { !$0.isEmpty && !$1.isEmpty }
			.subscribe(with: self) { owner, valid in
				loginValid.accept(valid)
			}
			.disposed(by: disposeBag)



		input.loginButtonTapped
			.debounce(.seconds(1), scheduler: MainScheduler.instance)
			.withLatestFrom(loginObservable.map { email, password in
				print(email, password)
				return LoginQuery(email: email, password: password)
			})
			.flatMap { loginQuery in
				print("\(loginQuery)) 이곳인가")
				return NetworkManager.createLogin(query: loginQuery)
					.catch { error -> Single<LoginModel> in
						errorMessage.accept("이메일 혹은 비밀번호가 올바르지 않습니다.")
						return Single.never()
							 }
					 }
			.subscribe(with: self, onNext: { owner, loginModel in
				print("통신성공")
				UserDefaults.standard.set(loginModel.user_id, forKey: UserDefaultsKey.userId.key)
				UserDefaults.standard.set(loginModel.accessToken, forKey: UserDefaultsKey.accessToken.key)
				UserDefaults.standard.set(loginModel.refreshToken, forKey: UserDefaultsKey.refreshToken.key)
				loginSuccessTrigger.accept(())
			})
					 .disposed(by: disposeBag)


		return Output(
			errorMessage: errorMessage.asDriver(onErrorJustReturn: ""),
			loginValidation: loginValid.asDriver(),
			loginSuccessTrigger: loginSuccessTrigger.asDriver(onErrorJustReturn: ())
		)
	}

	func handleAutoLogin(_ email: String, password: String, enable: Bool) {
		let keychain = KeychainSwift()
		if enable {
			keychain.set(email, forKey: "userEmail")
			keychain.set(password, forKey: "userPassword")
			UserDefaults.standard.set(true, forKey: "autoLoginEnabled")
		} else {
			keychain.delete("userEmail")
			keychain.delete("userPassword")
			UserDefaults.standard.set(false, forKey: "autoLoginEnabled")
		}
	}
	
	func checkAutoLogin() -> (email: String?, password: String?) {
		let keychain = KeychainSwift()
		if UserDefaults.standard.bool(forKey: "autoLoginEnabled") {
			let email = keychain.get("userEmail")
			let password = keychain.get("userPassword")
			return (email, password)
		}
		return (nil, nil)
	}

}


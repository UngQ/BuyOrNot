//
//  SignInViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SignInViewModel: ViewModelType {

	var disposeBag = DisposeBag()

	struct Input {
		let emailText: Observable<String>
		let passwordText: Observable<String>
		let loginButtonTapped: Observable<Void>
	}

	struct Output {
		let loginValidation: Driver<Bool>
		let loginSuccessTrigger: Driver<Void>
	}

	func transform(input: Input) -> Output {

		let loginValid = BehaviorRelay(value: false)
		let loginSuccessTrigger = PublishRelay<Void>()

		let loginObservable = Observable.combineLatest(
			input.emailText,
			input.passwordText
		)
			.map { email, password in
				return LoginQuery(email: email, password: password)
			}

		loginObservable
			.bind(with: self) { owner, login in
				if login.email.contains("@") && login.password.count > 3 {
					loginValid.accept(true)
				} else {
					loginValid.accept(false)
				}
			}
			.disposed(by: disposeBag)

		input.loginButtonTapped
			.debounce(.seconds(1), scheduler: MainScheduler.instance)
			.withLatestFrom(loginObservable)
			.flatMap { loginQuery in
				return NetworkManager.createLogin(query: loginQuery)
			}
			.subscribe(with: self) { owner, loginModel in
				UserDefaults.standard.set(loginModel.accessToken, forKey: "token")
				UserDefaults.standard.set(loginModel.refreshToken, forKey: "refreshToken")
				loginSuccessTrigger.accept(())
			} onError: { owner, error in
				print("오류 발생")
			}
			.disposed(by: disposeBag)



		return Output(
			loginValidation: loginValid.asDriver(),
			loginSuccessTrigger: loginSuccessTrigger.asDriver(onErrorJustReturn: ())
		)
	}


}


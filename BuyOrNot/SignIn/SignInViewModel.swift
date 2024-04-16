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
			.map { email, password in
				print(email, password)
				return LoginQuery(email: email, password: password)
			}

//		loginObservable
//			.bind(with: self) { owner, login in
//				if login.email.contains("@") && login.password.count > 3 {
//					loginValid.accept(true)
//				} else {
//					loginValid.accept(false)
//				}
//			}
//			.disposed(by: disposeBag)

		input.loginButtonTapped
			.debounce(.seconds(1), scheduler: MainScheduler.instance)
			.withLatestFrom(loginObservable)
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


}


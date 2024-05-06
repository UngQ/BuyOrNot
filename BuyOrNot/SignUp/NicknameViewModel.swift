//
//  NicknameViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import Foundation
import RxSwift
import RxCocoa

final class NicknameViewModel: ViewModelType {

	var disposeBag: DisposeBag = DisposeBag()

	struct Input {
		let nickname: ControlProperty<String>
		let nextButtonTap: ControlEvent<Void>
	}

	struct Output {
		let isValidation: Driver<Bool>
		let isCompleteJoin: Driver<Bool>
	}

	func transform(input: Input) -> Output {
		let isValidation = PublishRelay<Bool>()
		let isCompleteJoin = PublishRelay<Bool>()


		input.nickname
			.map { self.isValidNickname($0) }
			.bind(with: self) { owner, result in
				isValidation.accept(result)
			}
			.disposed(by: disposeBag)

		input.nextButtonTap
			.withLatestFrom(input.nickname)
			.flatMapLatest { nickname -> Single<LoginModel> in
				guard self.isValidNickname(nickname) else { return Single.never() }

				guard let email = UserDefaults.standard.string(forKey: UserDefaultsKey.email.key) else { return Single.never() }
				guard let password = UserDefaults.standard.string(forKey: UserDefaultsKey.password.key) else { return Single.never() }

				let joinQuery = JoinQuery(email: email,
										  password: password,
										  nick: nickname)

				return NetworkManager.performRequest(route: .join(query: joinQuery), decodingType: JoinModel.self)
					.flatMap { join -> Single<LoginModel> in
						let loginQuery = LoginQuery(email: joinQuery.email, password: joinQuery.password)
						return NetworkManager.performRequest(route: .login(query: loginQuery), decodingType: LoginModel.self)
					}
			}
			.subscribe(with: self) { owner, login in
				UserDefaults.standard.setValue(login.user_id, forKey: UserDefaultsKey.userId.key)
				UserDefaults.standard.setValue(login.email, forKey: UserDefaultsKey.email.key)
				UserDefaults.standard.setValue(login.nick, forKey: UserDefaultsKey.nick.key)
				UserDefaults.standard.setValue(login.accessToken, forKey: UserDefaultsKey.accessToken.key)
				UserDefaults.standard.setValue(login.refreshToken, forKey: UserDefaultsKey.refreshToken.key)
				isCompleteJoin.accept(true)
			}
			.disposed(by: disposeBag)



		return Output(isValidation: isValidation.asDriver(onErrorJustReturn: false),
					  isCompleteJoin: isCompleteJoin.asDriver(onErrorJustReturn: false))
	}

	func isValidNickname(_ nickname: String) -> Bool {
		let nicknameRegex = "^[a-zA-Z0-9가-힣]{3,10}$"
		return NSPredicate(format: "SELF MATCHES %@", nicknameRegex).evaluate(with: nickname)
	}
}

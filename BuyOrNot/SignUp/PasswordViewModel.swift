//
//  PasswordViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import Foundation
import RxSwift
import RxCocoa

class PasswordViewModel: ViewModelType {

	var disposeBag: DisposeBag = DisposeBag()

	struct Input {
		let passwordText: ControlProperty<String>
		let confirmPasswordText: ControlProperty<String>

	}

	struct Output {
		let initValid: Driver<Bool>
		let finalValid: Driver<Bool>
	}

	func transform(input: Input) -> Output {

		let initValid = PublishRelay<Bool>()
		let finalValid = PublishRelay<Bool>()
		let combineText = Observable.combineLatest(input.passwordText,
											input.confirmPasswordText)

		input.passwordText
			.map { self.isValidPassword($0) }
			.subscribe(with: self) { owner, valid in
				initValid.accept(valid)

			}
			.disposed(by: disposeBag)

		combineText.map {
			print($0, $1)
			return $0 == $1 }
			.bind(to: finalValid)
			.disposed(by: disposeBag)


		return Output(initValid: initValid.asDriver(onErrorJustReturn: false),
					  finalValid: finalValid.asDriver(onErrorJustReturn: false))
	}

	func isValidPassword(_ password: String) -> Bool {
		let passwordRegex = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z])(?=.*[!@#$&*]).{8,16}$"
		return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
	}

}

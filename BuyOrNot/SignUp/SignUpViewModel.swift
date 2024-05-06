//
//  SignUpViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SignUpViewModel: ViewModelType {

	var disposeBag: DisposeBag = DisposeBag()

	struct Input {
		let emailTextField: ControlProperty<String>
		let validationButtonTap: ControlEvent<Void>
	}

	struct Output {
		let validationMessage: Driver<String>
		let isvalidationButtonEnable: Driver<Bool>
		let isValidation: Driver<Bool>

	}

	func transform(input: Input) -> Output {
		let validationMessage = PublishRelay<String>()
		let isvalidationButtonEnable = BehaviorRelay(value: false)
		let isValidation = BehaviorRelay(value: false)


		input.emailTextField
			.map { !$0.isEmpty }
			.subscribe(with: self) { owner, valid in
				isvalidationButtonEnable.accept(valid)
			}
			.disposed(by: disposeBag)

		input.emailTextField.subscribe { value in
			isValidation.accept(false)
		}.disposed(by: disposeBag)

		input.validationButtonTap
			.withLatestFrom(input.emailTextField)
			.flatMap {
				if self.isValidEmail($0) {
					return NetworkManager.performRequest(route: .validationEmail(query: ValidationEmailQuery(email: $0)), decodingType: MessageModel.self)

						.catch { error in
							if let errorCode = error.asAFError?.responseCode, errorCode == 409 {
								validationMessage.accept("이미 사용 중인 이메일 입니다.")
							} else {
								validationMessage.accept("네트워크 오류 발생")
							}
							return Single<MessageModel>.never()
						}
				} else {
					validationMessage.accept("유효하지 않은 이메일 형식입니다.")
					return Single<MessageModel>.never()
				}
			}
			.subscribe(onNext: { message in

				validationMessage.accept(message.message)

				isValidation.accept(true)
			})
			.disposed(by: disposeBag)



		return Output(validationMessage: validationMessage.asDriver(onErrorJustReturn: ""),
					  isvalidationButtonEnable: isvalidationButtonEnable.asDriver(),
					  isValidation: isValidation.asDriver(onErrorJustReturn: false))
	}

	func isValidEmail(_ email: String) -> Bool {
		let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
		return emailTest.evaluate(with: email)
	}

}

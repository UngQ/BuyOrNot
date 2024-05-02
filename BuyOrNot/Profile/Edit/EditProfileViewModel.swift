//
//  EditProfileViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 5/2/24.
//

import Foundation
import RxSwift
import RxCocoa

class EditProfileViewModel: ViewModelType {

	var disposeBag = DisposeBag()
	
	let profileData = BehaviorRelay<ProfileModel>(value: ProfileModel(user_id: "", nick: "", profileImage: "", followers: [], following: [], posts: []))

	var profileImage: Data? = nil

	struct Input {

		let nicknameText: ControlProperty<String>

		let saveButtonTapped: Observable<Void>
	}

	struct Output {
		let isValidation: Driver<Bool>
		let successTrigger: Driver<Void>

	}

	func transform(input: Input) -> Output {
		let isValidation = PublishRelay<Bool>()
		let successTrigger = PublishRelay<Void>()

		input.nicknameText
			.map { self.isValidNickname($0) }
			.bind(with: self) { owner, result in
				isValidation.accept(result)
			}
			.disposed(by: disposeBag)

		input.saveButtonTapped
			.withLatestFrom(input.nicknameText)
			.flatMap {
				let query = ProfileQuery(nick: $0, file: self.profileImage)
				return NetworkManager.performRequest(route: .editProfile(query: query), decodingType: ProfileModel.self)
					.catch { error in
							.never()
					}
			}
			.subscribe(with: self) { owner, result in
				print(result)
				successTrigger.accept(())
			}
			.disposed(by: disposeBag)

		return Output(isValidation: isValidation.asDriver(onErrorJustReturn: false),
					  successTrigger: successTrigger.asDriver(onErrorJustReturn: ()))
	}

	func isValidNickname(_ nickname: String) -> Bool {
		let nicknameRegex = "^[a-zA-Z0-9가-힣]{3,10}$"
		return NSPredicate(format: "SELF MATCHES %@", nicknameRegex).evaluate(with: nickname)
	}
}

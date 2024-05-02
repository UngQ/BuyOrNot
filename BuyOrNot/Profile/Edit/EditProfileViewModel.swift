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

		let saveButtonTapped: ControlEvent<Void>
	}

	struct Output {
		let successTrigger: Driver<Void>

	}

	func transform(input: Input) -> Output {
		let successTrigger = PublishRelay<Void>()

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

		return Output(successTrigger: successTrigger.asDriver(onErrorJustReturn: ()))
	}
}

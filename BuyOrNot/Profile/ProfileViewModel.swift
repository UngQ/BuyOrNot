//
//  ProfileViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 4/21/24.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileViewModel: ViewModelType {

	var myOrOther = true
	var othersId: String = ""

	var disposeBag = DisposeBag()

	let viewWillAppearTrigger = PublishRelay<Void>()
	let profileData = BehaviorRelay<ProfileModel>(value: ProfileModel(user_id: "", nick: "", profileImage: "", followers: [], following: [], posts: []))
	let followingData = BehaviorRelay<ProfileModel>(value: ProfileModel(user_id: "", nick: "", profileImage: "", followers: [], following: [], posts: []))


	struct Input {

	}

	struct Output {
		let data: Driver<ProfileModel>
		let followingData: Driver<ProfileModel>
	}

	func transform(input: Input) -> Output {


		if myOrOther {

			viewWillAppearTrigger
				.flatMap {
					
					NetworkManager.performRequest(route: .myProfile, decodingType: ProfileModel.self)
						.catch { error in
							print(error.asAFError?.responseCode)
							return Single.never()
						}
				}
				.subscribe(with: self) { owner, data in

					owner.profileData.accept(data)
				}
				.disposed(by: disposeBag)
		} else {
			let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""

			viewWillAppearTrigger
				.flatMap {
					NetworkManager.performRequest(route: .othersProfile(id: self.othersId), decodingType: ProfileModel.self)
						.catch { error in
							print(error.asAFError?.responseCode)
							return Single.never()
						}
				}
				.subscribe(with: self) { owner, data in

					let followerIds = data.followers.map { $0.user_id }
					let isFollower = followerIds.contains(myId)


					owner.profileData.accept(data)
				}
				.disposed(by: disposeBag)

		}

		return Output(data: profileData.asDriver(),
					  followingData: followingData.asDriver())
	}

}

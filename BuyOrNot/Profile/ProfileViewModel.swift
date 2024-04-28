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
	let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""
	let myNick = UserDefaults.standard.string(forKey: UserDefaultsKey.nick.key) ?? ""


	struct Input {

		let navigationRightButtonTapped: ControlEvent<Void>
	}

	struct Output {
		let data: Driver<ProfileModel>
		let navigationRightButtonTapped: Driver<Void>
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
					let isFollower = followerIds.contains(owner.myId)


					owner.profileData.accept(data)
				}
				.disposed(by: disposeBag)

			input.navigationRightButtonTapped
				.flatMap {
					var newProfileData = self.profileData.value
					if let index = newProfileData.followers.firstIndex(where: { $0.user_id == self.myId }) {

						 newProfileData.followers.remove(at: index)
					 } else {
						 // If not found, add as new follower
						 let myData = CreatorModel(user_id: self.myId, nick: self.myNick, profileImage: "")
						 newProfileData.followers.append(myData)
					 }
					 self.profileData.accept(newProfileData)

					return NetworkManager.performRequest(route: .plusFollow(id: self.othersId), decodingType: FollowModel.self)
						.catch { error in
							if error.asAFError?.responseCode == 409 {
								print("언팔 하셔야죠")
								return NetworkManager.performRequest(route: .deleteFollow(id: self.othersId), decodingType: FollowModel.self)
									.catch { _ in
										return Single.never()
									}

							} else {
								return Single.never()
							}
						}
				}
				.subscribe(with: self) { owner, result in

					print("팔로우/언팔 완료")
				}
				.disposed(by: disposeBag)

		}

		return Output(data: profileData.asDriver(),
					  navigationRightButtonTapped: input.navigationRightButtonTapped.asDriver())
	}

}

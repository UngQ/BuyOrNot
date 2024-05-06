//
//  ProfileViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 4/21/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileViewModel: ViewModelType {

	var myOrOther = true
	var othersId: String = ""
	var followerOrFollowing = true

	var disposeBag = DisposeBag()

	let viewWillAppearTrigger = PublishRelay<Void>()
	let profileData = BehaviorRelay<ProfileModel>(value: ProfileModel(user_id: "", nick: "", profileImage: "", followers: [], following: [], posts: []))

	//다른 프로필 들어갈 경우, 내 팔로잉과 비교용
	var myFollowingData: [CreatorModel] = []
	let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""
	let myNick = UserDefaults.standard.string(forKey: UserDefaultsKey.nick.key) ?? ""


	struct Input {

		let navigationRightButtonTapped: ControlEvent<Void>?
		let deleteButtonTapped: Observable<Int>?
		let unfollowButtonTapped: Observable<Int>?
		let followButtonTapped: Observable<Int>?
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
					owner.myFollowingData = data.following
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

			//내 프로필과 비교용
			viewWillAppearTrigger
				.flatMap {
					NetworkManager.performRequest(route: .myProfile, decodingType: ProfileModel.self)
						.catch { error in
							print(error.asAFError?.responseCode)
							return Single.never()
						}
				}
				.subscribe(with: self) { owner, data in
					owner.myFollowingData = data.following

				}
				.disposed(by: disposeBag)

			input.navigationRightButtonTapped?
				.flatMap {
					var newProfileData = self.profileData.value
					if let index = newProfileData.followers.firstIndex(where: { $0.user_id == self.myId }) {

						 newProfileData.followers.remove(at: index)
					 } else {
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

		input.deleteButtonTapped?
			.withLatestFrom(profileData) { index, profileData -> (CreatorModel?, Int) in

				print(index)
				
				guard index < profileData.following.count else { return (nil, 0) }
				return (profileData.following[index], index)
			}

			.flatMap { (following, index) -> Single<FollowModel> in

				guard let following = following else {
				 return Single.never()
			 }


				var newData = self.profileData.value
				newData.following.remove(at: index)

				self.profileData.accept(newData)
				return NetworkManager.performRequest(route: .deleteFollow(id: following.user_id), decodingType: FollowModel.self)
			}
			.subscribe(with: self, onNext: { owner, deletedFollow in
				print("삭제 성공")
			})
			.disposed(by: disposeBag)

		input.unfollowButtonTapped?
			.withLatestFrom(profileData) { index, profileData -> (CreatorModel?, Int) in

				if self.followerOrFollowing {
					guard index < profileData.followers.count else { return (nil, 0) }
					return (profileData.followers[index], index)
				} else {
					guard index < profileData.following.count else { return (nil, 0) }
					return (profileData.following[index], index)
				}
			}

			.flatMap { (follow, index) -> Single<FollowModel> in

				print("HiHI")
				guard let follow = follow else {
				 return Single.never()
			 }
				print("HiHI")

				var newData = self.profileData.value
				self.myFollowingData.removeAll { $0.user_id == follow.user_id }

				self.profileData.accept(newData)
				return NetworkManager.performRequest(route: .deleteFollow(id: follow.user_id), decodingType: FollowModel.self)
					.catch { error in
						print(error.localizedDescription)
						return .never()
					}
			}
			.subscribe(with: self, onNext: { owner, deletedFollow in
				print("삭제 성공")
			})
			.disposed(by: disposeBag)

		input.followButtonTapped?
			.withLatestFrom(profileData) { index, profileData -> (CreatorModel?, Int) in

				if self.followerOrFollowing {
					guard index < profileData.followers.count else { return (nil, 0) }
					return (profileData.followers[index], index)
				} else {
					guard index < profileData.following.count else { return (nil, 0) }
					return (profileData.following[index], index)
				}
			}

			.flatMap { (follow, index) -> Single<FollowModel> in

				print("HiHI")
				guard let follow = follow else {
					return Single.never()
				}
				print("HiHI")

				var newData = self.profileData.value
				self.myFollowingData.append(follow)

				self.profileData.accept(newData)
				return NetworkManager.performRequest(route: .plusFollow(id: follow.user_id), decodingType: FollowModel.self)
					.catch { error in
						print(error.localizedDescription)
						return .never()
					}
			}
			.subscribe(with: self) { owner, row in
				print("팔로우 성공")
			}
			.disposed(by: disposeBag)

		return Output(data: profileData.asDriver(),
					  navigationRightButtonTapped: input.navigationRightButtonTapped?.asDriver() ?? Driver.never())
	}

}

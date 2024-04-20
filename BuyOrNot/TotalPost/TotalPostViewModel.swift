//
//  TotalPostViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import Foundation
import RxSwift
import RxCocoa
import Kingfisher


class TotalPostViewModel: ViewModelType {

	var disposeBag = DisposeBag()

	let viewWillAppearTrigger = PublishRelay<Void>()
	private let postsData = BehaviorRelay<[PostModel]>(value: [])


	struct Input {
		let likeButtonTap: Observable<Int>
		let disLikeButtonTap: Observable<Int>
	}

	struct Output {

		let data: Driver<[PostModel]>
		let cautionMessage: Driver<String>

	}

	func transform(input: Input) -> Output {

		let message = BehaviorRelay(value: "")

		viewWillAppearTrigger
			.flatMap {
				NetworkManager.performRequest(route: .lookPosts(query: PostQueryItems(next: nil, limit: "20", hashTag: nil)), decodingType: PostsModel.self)
					.catch { error in
						print(error.asAFError?.responseCode)
						return Single.never()
					}
			}
			.subscribe(with: self) { owner, result in
				owner.postsData.accept(result.data)
			}
			.disposed(by: disposeBag)

		input.likeButtonTap
			.withLatestFrom(postsData) { index, posts -> PostModel? in

				guard index < posts.count else { return nil }
				print(posts[index])
				return posts[index]
			}
			.flatMap { post -> Single<LikeQueryAndModel> in
				print("2")
				guard let post = post else {
					return Single.never()
				}
				print("3")
				guard let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) else {
					return Single.never()
				}


				var like = post.likes.contains(myId)

				if post.likes2.contains(myId) {
					message.accept("반대 투표는 투표취소 후 가능합니다.")
					return Single.never()
				}
				print("4")

				print(post.post_id)

				var newPosts = self.postsData.value
				if let idx = newPosts.firstIndex(where: { $0.post_id == post.post_id }) {
					if like {
						newPosts[idx].likes.removeAll(where: { $0 == UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? "" })
					} else {
						newPosts[idx].likes.append(UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? "")
					}
					self.postsData.accept(newPosts)  // Update the local data source
				}

				let result = NetworkManager.performRequest(route: .likePost(id: post.post_id, query:  LikeQueryAndModel(like_status: !like), like: "like"), decodingType: LikeQueryAndModel.self)
					.catch { error in
						print(error.asAFError?.errorDescription)

						return Single.never()
					}


				return result
			}.subscribe(with: self) { owner, value in
				print(value.like_status)
			}
			.disposed(by: disposeBag)


		input.disLikeButtonTap
			.withLatestFrom(postsData) { index, posts -> PostModel? in

				guard index < posts.count else { return nil }
				print(posts[index])
				return posts[index]
			}
			.flatMap { post -> Single<LikeQueryAndModel> in
				print("2")
				guard let post = post else {
					return Single.never()
				}
				print("3")
				guard let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) else {
					return Single.never()
				}



				var like = post.likes2.contains(myId)
				print("4")

				if post.likes.contains(myId) {
					message.accept("반대 투표는 투표취소 후 가능합니다.")
					return Single.never()
				}

				print(post.post_id)

				var newPosts = self.postsData.value
				if let idx = newPosts.firstIndex(where: { $0.post_id == post.post_id }) {
					if like {
						newPosts[idx].likes2.removeAll(where: { $0 == UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? "" })
					} else {
						newPosts[idx].likes2.append(UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? "")
					}
					self.postsData.accept(newPosts)  // Update the local data source
				}

				let result = NetworkManager.performRequest(route: .likePost(id: post.post_id, query:  LikeQueryAndModel(like_status: !like), like: "like-2"), decodingType: LikeQueryAndModel.self)
					.catch { error in
						print(error.asAFError?.errorDescription)

						return Single.never()
					}


				return result
			}.subscribe(with: self) { owner, value in
				print(value.like_status)
			}
			.disposed(by: disposeBag)



		return Output(data: postsData.asDriver(),
					  cautionMessage: message.asDriver())

	}



}

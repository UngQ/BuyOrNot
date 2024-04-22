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


class PostViewModel: ViewModelType {

	var totalOrDetail = true
	var id: String?
	var isLoading = false
	var nextCursor: String? = nil

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

		if totalOrDetail {
			viewWillAppearTrigger
				.flatMap {[weak self] _ -> Single<PostsModel> in
					guard let self = self else { return .never()}

				 if self.isLoading && self.nextCursor == "0" {
					 message.accept("더 이상 게시물이 없습니다.")
					 return .never()
				 }

				 return NetworkManager.performRequest(route: .lookPosts(query: PostQueryItems(next: self.nextCursor, limit: "5", hashTag: nil)), decodingType: PostsModel.self)
						.catch { error in
							print(error.asAFError?.responseCode)
							return Single.never()
						}

				}
				.subscribe(with: self) { owner, result in

					owner.nextCursor = result.next_cursor

					if !owner.isLoading {
						print("first")
						owner.postsData.accept(result.data)
					} else if owner.isLoading  {
						print("second")
						var newData = owner.postsData.value
						newData.append(contentsOf: result.data)
						owner.postsData.accept(newData)

					}

				}
				.disposed(by: disposeBag)
		} else {
			viewWillAppearTrigger
				.flatMap {
					NetworkManager.performRequest(route: .lookPost(id: self.id ?? ""), decodingType: PostModel.self)
						.catch { error in
							print(error.asAFError?.responseCode)
							return Single.never()
						}
				}
				.subscribe(with: self) { owner, result in
					owner.postsData.accept([result])
				}
				.disposed(by: disposeBag)


		}

		input.likeButtonTap
			.withLatestFrom(postsData) { index, posts -> PostModel? in
				print(index)
				guard index < posts.count else { return nil }
				print(posts[index])
				return posts[index]
			}
			.flatMap { post -> Single<LikeQueryAndModel> in

				guard let post = post else {
					return Single.never()
				}

				guard let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) else {
					return Single.never()
				}


				let like = post.likes.contains(myId)

				if post.likes2.contains(myId) {
					message.accept("반대 투표는 투표취소 후 가능합니다.")
					return Single.never()
				}


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
				print(index)

				guard index < posts.count else { return nil }
				print(posts[index])
				return posts[index]
			}
			.flatMap { post -> Single<LikeQueryAndModel> in

				guard let post = post else {
					return Single.never()
				}

				guard let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) else {
					return Single.never()
				}



				let like = post.likes2.contains(myId)


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

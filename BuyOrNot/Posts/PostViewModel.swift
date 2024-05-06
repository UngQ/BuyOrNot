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

final class PostViewModel: ViewModelType {

	var totalOrDetail = true
	var id: String?
	var isLoading = false
	var nextCursor: String? = nil

	var disposeBag = DisposeBag()

	let viewWillAppearTrigger = PublishRelay<Void>()
	private let postsData = BehaviorRelay<[PostModel]>(value: [])


	struct Input {
		let deleteButtonTap: Observable<Int>
		let likeButtonTap: Observable<Int>
		let disLikeButtonTap: Observable<Int>
	}

	struct Output {

		let data: Driver<[PostModel]>
		let cautionMessage: Driver<String>


	}

	func transform(input: Input) -> Output {

		let message = PublishRelay<String>()


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
				return posts[index]
			}
			.flatMap { post -> Single<LikeQueryAndModel> in


				guard let post = post, let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) else {
					return Single.never()
				}

				var newPosts = self.postsData.value
				let like = post.likes.contains(myId)
				let dislike = post.likes2.contains(myId)



				if let idx = newPosts.firstIndex(where: { $0.post_id == post.post_id }) {
						  if dislike {
							  newPosts[idx].likes2.removeAll(where: { $0 == myId })
						  }
						  if like {
							  newPosts[idx].likes.removeAll(where: { $0 == myId })
						  } else {
							  newPosts[idx].likes.append(myId)
						  }
						  self.postsData.accept(newPosts)
					  }

				let likeRequest = NetworkManager.performRequest(route: .likePost(id: post.post_id, query: LikeQueryAndModel(like_status: !like), like: "like"), decodingType: LikeQueryAndModel.self)

				let dislikeRequest = dislike ? NetworkManager.performRequest(route: .likePost(id: post.post_id, query: LikeQueryAndModel(like_status: false), like: "like-2"), decodingType: LikeQueryAndModel.self) : .just(LikeQueryAndModel(like_status: false))


					  return Single.zip(likeRequest, dislikeRequest) { likeResult, _ in
						  return likeResult
					  }
					  .catch { error in
						  print("Error during network request: \(error.localizedDescription)")
						  return .never()
					  }
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

				guard let post = post, let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) else {
					return Single.never()
				}

				var newPosts = self.postsData.value
				let like = post.likes.contains(myId)
				let dislike = post.likes2.contains(myId)

				if let idx = newPosts.firstIndex(where: { $0.post_id == post.post_id }) {
					if like {
						newPosts[idx].likes.removeAll(where: { $0 == myId })
					}

					if dislike {
						newPosts[idx].likes2.removeAll { $0 == myId }

					} else {
						newPosts[idx].likes2.append(myId)
					}

					self.postsData.accept(newPosts)


				}


				let likeRequest = like ? NetworkManager.performRequest(route: .likePost(id: post.post_id, query: LikeQueryAndModel(like_status: false), like: "like"), decodingType: LikeQueryAndModel.self) : .just(LikeQueryAndModel(like_status: false))
				let dislikeRequest = NetworkManager.performRequest(route: .likePost(id: post.post_id, query: LikeQueryAndModel(like_status: !dislike), like: "like-2"), decodingType: LikeQueryAndModel.self)

				return Single.zip(likeRequest, dislikeRequest) { _, dislikeResult in
				return dislikeResult }
				.catch { error in
					print(error.localizedDescription)
					return .never()
				}
			}.subscribe(with: self) { owner, value in
				print(value.like_status)
			}
			.disposed(by: disposeBag)

		input.deleteButtonTap
			.flatMap {
				print(self.postsData.value[$0])
				return NetworkManager.performRequestVoidType(route: .deletePost(id: self.postsData.value[$0].post_id))
			}
			.subscribe(with: self, onNext: { owner, _ in
				print("포스트 삭제성공")
				owner.isLoading = false
				owner.nextCursor = nil
				owner.postsData.accept([])

			})
			.disposed(by: disposeBag)


		return Output(data: postsData.asDriver(),
					  cautionMessage: message.asDriver(onErrorJustReturn: ""))

	}



}

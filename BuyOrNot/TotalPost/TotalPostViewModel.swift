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
	}

	struct Output {

		let data: Driver<[PostModel]>
	
	}

	func transform(input: Input) -> Output {
//		let data = dataRelay.asDriver(onErrorJustReturn: [])

		viewWillAppearTrigger
			.flatMap {
				NetworkManager.performRequest(route: .lookPosts(query: PostQueryItems(next: nil, limit: "20")), decodingType: PostsModel.self)
			}
			.subscribe(with: self) { owner, result in
				owner.postsData.accept(result.data)

			}
			.disposed(by: disposeBag)

//		input.likeButtonTap
//			.withLatestFrom(data) { index, posts -> PostModel? in
//
//					guard index < posts.count else { return nil }
//				print(posts[index])
//					return posts[index]
//				}
//				.flatMap { post -> Single<LikeQueryAndModel> in
//					print("2")
//					guard let post = post else {
//						return Single.never()
//					}
//					print("3")
//					guard let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) else {
//						return Single.never()
//					}
//
//
//					var like = post.likes.contains(myId)
//					print("4")
//
//					print(post.post_id)
//
//					let result = NetworkManager.performRequest(route: .likePost(id: post.post_id, query:  LikeQueryAndModel(like_status: !like)), decodingType: LikeQueryAndModel.self)
//						.catch { error in
//							print(error.asAFError?.errorDescription)
//
//							return Single.never()
//						}
//					
//
//					return result
//			}
		input.likeButtonTap
				.withLatestFrom(postsData) { index, posts -> (PostModel, Bool)? in
					guard index < posts.count else { return nil }
					let post = posts[index]
					let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""
					let isLiked = post.likes.contains(myId)
					return (post, isLiked)
				}
				.compactMap { $0 }
				.flatMap { (post, isLiked) -> Single<PostModel> in
					var newPosts = self.postsData.value
					if let idx = newPosts.firstIndex(where: { $0.post_id == post.post_id }) {
						if isLiked {
							newPosts[idx].likes.removeAll(where: { $0 == UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? "" })
						} else {
							newPosts[idx].likes.append(UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? "")
						}
						self.postsData.accept(newPosts)  // Update the local data source
					}

					print(post.post_id)
					return NetworkManager.performRequest(route: .likePost(id: post.post_id, query: LikeQueryAndModel(like_status: !isLiked)), decodingType: PostModel.self)
						.catch { error in
							print(error)
							return Single.never()
						}
				}
				.subscribe(onNext: { [weak self] updatedPost in
					// Optionally update the local post with detailed data from the response if needed
				})
				.disposed(by: disposeBag)


		return Output(data: postsData.asDriver())

	}



}

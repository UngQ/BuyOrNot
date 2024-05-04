//
//  ContentPostViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 4/20/24.
//

import Foundation
import RxSwift
import RxCocoa

enum Content: Int {
	case categoryPosts
	case myPosts
	case likePosts
	case dislikePosts
}

class ContentPostViewModel: ViewModelType {

	var content: Content?


	var isLoading = false
	var nextCursor: String? = nil
	var title: String?
	var hashTag: String?
	var myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""


	var disposeBag = DisposeBag()

	let viewWillAppearTrigger = PublishRelay<Void>()
	let postsData = BehaviorRelay<[PostModel]>(value: [])


	struct Input {


	}

	struct Output {
		let data: Driver<[PostModel]>
		let cautionMessage: Driver<String>
	}

	func transform(input: Input) -> Output {
		let message = PublishRelay<String>()

		switch content {

		case .categoryPosts:

			viewWillAppearTrigger
				.flatMap { [weak self] _ -> Single<PostsModel> in
					guard let self = self else { return .never()}

					if self.isLoading && self.nextCursor == "0" {
						message.accept("더 이상 게시물이 없습니다.")
						return .never()
					}

					return NetworkManager.performRequest(route: .hashTag(query: PostQueryItems(next: self.nextCursor, limit: "21", hashTag: self.hashTag)), decodingType: PostsModel.self)
						.catch { error in
							print(error.asAFError?.responseCode)
							return Single.never()
						}
				}
				.subscribe(with: self) { owner, result in
					print("======\(result.next_cursor)======")
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
		case .myPosts:

			viewWillAppearTrigger
				.flatMap { [weak self] _ -> Single<PostsModel> in
					guard let self = self else { return .never()}

					if self.isLoading && self.nextCursor == "0" {
						message.accept("더 이상 게시물이 없습니다.")
						return .never()
					}

					return NetworkManager.performRequest(route: .userPost(query: PostQueryItems(next: self.nextCursor, limit: "20", hashTag: nil), id: myId), decodingType: PostsModel.self)
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


		case .likePosts:

			let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""

			viewWillAppearTrigger
				.flatMap {
					NetworkManager.performRequest(route: .myLikes(query: PostQueryItems(next: "", limit: "20", hashTag: nil)), decodingType: PostsModel.self)
						.catch { error in
							print(error.asAFError?.responseCode)
							return Single.never()
						}
				}
				.subscribe(with: self) { owner, data in

					owner.postsData.accept(data.data)
				}
				.disposed(by: disposeBag)

		case .dislikePosts:
			let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""

			viewWillAppearTrigger
				.flatMap {
					NetworkManager.performRequest(route: .myDislikes(query: PostQueryItems(next: "", limit: "20", hashTag: nil)), decodingType: PostsModel.self)
						.catch { error in
							print(error.asAFError?.responseCode)
							return Single.never()
						}
				}
				.subscribe(with: self) { owner, data in

					owner.postsData.accept(data.data)
				}
				.disposed(by: disposeBag)

		case nil:
			let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""

			viewWillAppearTrigger
				.flatMap {
					NetworkManager.performRequest(route: .userPost(query: PostQueryItems(next: "", limit: "20", hashTag: nil), id: myId), decodingType: PostsModel.self)
						.catch { error in
							print(error.asAFError?.responseCode)
							return Single.never()
						}
				}
				.subscribe(with: self) { owner, data in
					print(data)

					owner.postsData.accept(data.data)
				}
				.disposed(by: disposeBag)
		}



		return Output(data: postsData.asDriver(),
					  cautionMessage: message.asDriver(onErrorJustReturn: ""))
	}
}



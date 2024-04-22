//
//  ContentPostViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 4/20/24.
//

import Foundation
import RxSwift
import RxCocoa

class ContentPostViewModel: ViewModelType {

	var isLoading = false
	var nextCursor: String? = nil
	var title: String?
	var hashTag: String?

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
		let message = BehaviorRelay(value: "")

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

		return Output(data: postsData.asDriver(),
					  cautionMessage: message.asDriver())
	}
}



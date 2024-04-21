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

	}

	func transform(input: Input) -> Output {

		viewWillAppearTrigger
			.flatMap {
				NetworkManager.performRequest(route: .hashTag(query: PostQueryItems(next: self.nextCursor, limit: "21", hashTag: self.hashTag)), decodingType: PostsModel.self)
					.catch { error in
						print(error.asAFError?.responseCode)
						return Single.never()
					}
			}
			.subscribe(with: self) { owner, result in
				if !owner.isLoading {
					owner.nextCursor = result.next_cursor
					owner.postsData.accept(result.data)
				} else {
					var newData = owner.postsData.value
					newData.append(contentsOf: result.data)
					owner.postsData.accept(newData)
				}
				print(result)
			}
			.disposed(by: disposeBag)

		return Output(data: postsData.asDriver())
	}
}



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

	var hashTag: String?

	var disposeBag = DisposeBag()

	let viewWillAppearTrigger = PublishRelay<Void>()
	private let postsData = BehaviorRelay<[PostModel]>(value: [])


	struct Input {


	}

	struct Output {
		let data: Driver<[PostModel]>

	}

	func transform(input: Input) -> Output {

		viewWillAppearTrigger
			.flatMap {
				NetworkManager.performRequest(route: .hashTag(query: PostQueryItems(next: nil, limit: "20", hashTag: self.hashTag)), decodingType: PostsModel.self)
					.catch { error in
						print(error.asAFError?.responseCode)
						return Single.never()
					}
			}
			.subscribe(with: self) { owner, result in
				owner.postsData.accept(result.data)
				print(result)
			}
			.disposed(by: disposeBag)

		return Output(data: postsData.asDriver())
	}
}

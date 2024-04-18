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

struct PostWithImage {
	let post: PostsModel
	let image: [Data]
}

class TotalPostViewModel: ViewModelType {

	var disposeBag = DisposeBag()

	let viewWillAppearTrigger = PublishRelay<Void>()

	struct Input {

	}

	struct Output {
		let data: Driver<[PostModel]>

	}

	func transform(input: Input) -> Output {

		let data = PublishRelay<[PostModel]>()

		viewWillAppearTrigger
			.flatMap {
				NetworkManager.performRequest(route: .posts(query: PostQueryItems(next: nil, limit: "20")), decodingType: PostsModel.self)
			}
			.subscribe(with: self) { owner, result in
				data.accept(result.data)
				
			}
			.disposed(by: disposeBag)


		return Output(data: data.asDriver(onErrorJustReturn: [])
					  )
	}



}

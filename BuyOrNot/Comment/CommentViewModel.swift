//
//  CommentViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 4/22/24.
//

import Foundation
import RxSwift
import RxCocoa

class CommentViewModel: ViewModelType {

	var disposeBag: DisposeBag = DisposeBag()

	var postID = ""
	var comments: [CommentModel] = []
	let commentsData = BehaviorRelay<[CommentModel]>(value: [])


	struct Input {
		let commentText: ControlProperty<String>
		let sendButtonTap: ControlEvent<Void>
	}


	struct Output {
		let data: Driver<[CommentModel]>
		let isValidation: Driver<Bool>
		
	}

	func transform(input: Input) -> Output {
		let isValidation = PublishRelay<Bool>()

		input.commentText
			.map { !$0.isEmpty }  // 텍스트가 비어있지 않으면 true, 비어있으면 false 반환
			.bind(to: isValidation)  // 결과를 isValidation에 바인딩
			.disposed(by: disposeBag)

		input.sendButtonTap
			.withLatestFrom(input.commentText)
			.flatMap {
				NetworkManager.performRequest(route: .uploadComment(id: self.postID, query: CommentQuery(content: $0)), decodingType: CommentModel.self)}
			.subscribe(with: self) { owner, comment in
				var newData = owner.commentsData.value
				newData.insert(comment, at: 0)

				self.commentsData.accept(newData)

			}
			.disposed(by: disposeBag)



		return Output(data: commentsData.asDriver(),
					  isValidation: isValidation.asDriver(onErrorJustReturn: false))
	}
}

//
//  EditCommentViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 5/2/24.
//

import Foundation
import RxSwift
import RxCocoa

class EditCommentViewModel: ViewModelType {

	var disposeBag = DisposeBag()
	var postId = ""
	var commentId = ""

	struct Input {
		let commentText: ControlProperty<String>
		let completedButtonTapped: ControlEvent<Void>
	}

	struct Output {
		let completedMessage: Driver<String>

	}

	func transform(input: Input) -> Output {
		let message = PublishRelay<String>()

		input.completedButtonTapped
			.withLatestFrom(input.commentText)
			.flatMap {
				NetworkManager.performRequest(route: .updateComment(id: self.postId, commentId: self.commentId, query: CommentQuery(content: $0)), decodingType: CommentModel.self)
				}
			.subscribe(with: self) { owner, result in
				message.accept("수정이 완료되었습니다.")
			}
			.disposed(by: disposeBag)

		return Output(completedMessage: message.asDriver(onErrorJustReturn: ""))
	}
}

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
	let commentsData = BehaviorRelay<[CommentModel]>(value: [])
	let modifyComment = PublishSubject<String>()
	let viewWillAppearTrigger = PublishRelay<Void>()

	struct Input {
		let commentText: ControlProperty<String>
		let sendButtonTap: ControlEvent<Void>
		let editButtonTap: Observable<Int>
		let deleteButtonTap: Observable<Int>

	}


	struct Output {
		let data: Driver<[CommentModel]>
		let isValidation: Driver<Bool>
		let deletedMessage: Driver<String>


	}

	func transform(input: Input) -> Output {
		let isValidation = PublishRelay<Bool>()
		let message = PublishRelay<String>()


		viewWillAppearTrigger
			.flatMap {
				NetworkManager.performRequest(route: .lookPost(id: self.postID), decodingType: PostModel.self)
					.catch { error in
						print(error.asAFError?.responseCode)
						return Single.never()
					}
			}
			.subscribe(with: self) { owner, result in
				owner.commentsData.accept(result.comments)
			}
			.disposed(by: disposeBag)

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

		input.deleteButtonTap
			.withLatestFrom(commentsData) { index, comments -> CommentModel? in
				print(index)
				guard index < comments.count else { return nil }
				return comments[index]
			}
			.flatMap { post -> Single<Void> in

				guard let post = post else {
					return Single.never()
				}

				return NetworkManager.performRequestVoidType(route: .deleteComment(id: self.postID, commentId: post.comment_id))
			}.subscribe(with: self) { owner, value in
				print("삭제버튼")
				message.accept("댓글을 삭제하였습니다.")
				owner.viewWillAppearTrigger.accept(())
			}
			.disposed(by: disposeBag)


		return Output(data: commentsData.asDriver(),
					  isValidation: isValidation.asDriver(onErrorJustReturn: false),
					  deletedMessage: message.asDriver(onErrorJustReturn: ""))
	}
}

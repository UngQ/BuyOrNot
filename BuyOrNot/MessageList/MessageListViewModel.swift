//
//  MessageListViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 5/17/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MessageListViewModel: ViewModelType {

	var disposeBag: DisposeBag = DisposeBag()


	let viewDidLoadTrigger = PublishRelay<Void>()
	let chatListData = BehaviorRelay<ChatListModel>(value: ChatListModel(data: []))


	struct Input {

	}

	struct Output {
		let data: Driver<ChatListModel>

	}


	func transform(input: Input) -> Output {
		viewDidLoadTrigger
			.flatMap {
				NetworkManager.performRequest(route: .myChats, decodingType: ChatListModel.self)
		}
			.subscribe(with: self) { owner, result in
				owner.chatListData.accept(result)
			}
			.disposed(by: disposeBag)

		return Output(data: chatListData.asDriver())
	}
}

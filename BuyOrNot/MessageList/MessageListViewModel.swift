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


	let viewWillAppearTrigger = PublishRelay<Void>()
	let viewWillDisappearTrigger = PublishRelay<Void>()
	let chatListData = BehaviorRelay<ChatListModel>(value: ChatListModel(data: []))


	struct Input {

	}

	struct Output {
		let data: Driver<ChatListModel>

	}


	func transform(input: Input) -> Output {

		viewWillAppearTrigger
			.flatMapLatest { [weak self] in
				self?.createTimerObservable() ?? Observable.empty()
			}
			.flatMap {
				NetworkManager.performRequest(route: .myChats, decodingType: ChatListModel.self)
		}
			.subscribe(with: self) { owner, result in
				owner.chatListData.accept(result)
			}
			.disposed(by: disposeBag)

		return Output(data: chatListData.asDriver())
	}

	private func createTimerObservable() -> Observable<Void> {
		return Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
			.map { _ in }
			.take(until: viewWillDisappearTrigger)
	}
}

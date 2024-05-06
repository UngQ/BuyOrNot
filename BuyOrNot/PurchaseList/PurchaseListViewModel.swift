//
//  PurchaseListViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 5/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PurchaseListViewModel: ViewModelType {

	var disposeBag: DisposeBag = DisposeBag()


	let viewDidLoadTrigger = PublishRelay<Void>()
	let postsData = BehaviorRelay<PaymentsDataListModel>(value: PaymentsDataListModel(data: []))


	struct Input {

	}

	struct Output {
		let data: Driver<PaymentsDataListModel>

	}


	func transform(input: Input) -> Output {
		viewDidLoadTrigger
			.flatMap {
				NetworkManager.performRequest(route: .paymentList, decodingType: PaymentsDataListModel.self)
		}
			.subscribe(with: self) { owner, result in
				owner.postsData.accept(result)
			}
			.disposed(by: disposeBag)

		return Output(data: postsData.asDriver())
	}
}

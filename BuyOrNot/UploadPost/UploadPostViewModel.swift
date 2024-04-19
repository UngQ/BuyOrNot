//
//  UploadPostViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 4/16/24.
//

import Foundation
import RxSwift
import RxCocoa

class UploadPostViewModel: ViewModelType {

    var disposeBag: DisposeBag = DisposeBag()
	var category = ""
	var image = [""]

	struct Input {
		let titleText: ControlProperty<String>
		let priceText: ControlProperty<String>
		let postButtonClicked:  ControlEvent<Void>
	}

	struct Output {
		let formattedPrice: Driver<String>
		let valid: Driver<Bool>
		let isPostCompleted: Driver<Bool>

	}

	func transform(input: Input) -> Output {
		let formattedPrice = PublishRelay<String>()
		let valid = PublishRelay<Bool>()
		let isPostCompleted = PublishRelay<Bool>()


		input.priceText.asObservable()
			.map { "\(self.formatNumber($0)) 원" }
			.bind(to: formattedPrice)
			.disposed(by: disposeBag)

		Observable.combineLatest(input.titleText, input.priceText)
			 .map { !$0.isEmpty && !$1.isEmpty }
			 .bind(to: valid)
			 .disposed(by: disposeBag)

		let test = Observable.combineLatest(input.titleText, input.priceText)

		input.postButtonClicked
			.withLatestFrom(test)
			.flatMapLatest { title, price -> Single<PostModel> in
				let query = PostQuery(title: title, content: self.category, content1: price, files: self.image)
//				PostQuery

				print(query)
				return NetworkManager.performRequest(route: .uploadPost(query: query), decodingType: PostModel.self)
			}
			.subscribe(with: self, onNext: { owner, result in
				print(result)
				isPostCompleted.accept(true)
			})

			.disposed(by: disposeBag)



		return Output(formattedPrice: formattedPrice.asDriver(onErrorJustReturn: ""),
					  valid: valid.asDriver(onErrorJustReturn: false),
					  isPostCompleted: isPostCompleted.asDriver(onErrorJustReturn: false))
	}

	func formatNumber(_ string: String) -> String {

		let numberFormatter: NumberFormatter = {
			let formatter = NumberFormatter()
			formatter.numberStyle = .decimal
			formatter.groupingSeparator = ","
			return formatter
		}()

		 let cleanedNumberString = string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
		 let formattedNumber = numberFormatter.string(from: NSNumber(value: Int(cleanedNumberString) ?? 0)) ?? ""
		 return formattedNumber
	 }
}

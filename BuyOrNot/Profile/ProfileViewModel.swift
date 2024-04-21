//
//  ProfileViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 4/21/24.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileViewModel: ViewModelType {

	var disposeBag = DisposeBag()

	let viewWillAppearTrigger = PublishRelay<Void>()
	let postsData = BehaviorRelay<[PostModel]>(value: [])


	struct Input {

	}

	struct Output {
		let data: Driver<[PostModel]>
	}

	func transform(input: Input) -> Output {
		let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""

		viewWillAppearTrigger
			.flatMap {
				NetworkManager.performRequest(route: .userPost(query: PostQueryItems(next: "", limit: "20", hashTag: nil), id: myId), decodingType: PostsModel.self)
					.catch { error in
						print(error.asAFError?.responseCode)
						return Single.never()
					}
			}
			.subscribe(with: self) { owner, data in
				print(data)

				owner.postsData.accept(data.data)
			}
			.disposed(by: disposeBag)

		return Output(data: postsData.asDriver())
	}

}

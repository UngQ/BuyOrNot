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

	}

	struct Output {

	}

	func transform(input: Input) -> Output {
		return Output()
	}
}

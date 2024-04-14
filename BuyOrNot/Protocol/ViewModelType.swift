//
//  ViewModelType.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import Foundation
import RxSwift

protocol ViewModelType {

	associatedtype Input
	associatedtype Output

	var disposeBag: DisposeBag { get set }

	func transform(input: Input) -> Output
}



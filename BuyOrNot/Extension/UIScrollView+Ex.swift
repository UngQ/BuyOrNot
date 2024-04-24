//
//  Reactive+Ex.swift
//  BuyOrNot
//
//  Created by ungQ on 4/22/24.
//

import UIKit
import RxSwift

extension Reactive where Base: UIScrollView {
	var reachedBottom: Observable<Void> {
		return contentOffset
			.debounce(.milliseconds(100), scheduler: MainScheduler.instance)
			.flatMap { [weak base] _ -> Observable<Void> in
				guard let scrollView = base else { return .empty() }
				let contentHeight = scrollView.contentSize.height
				let scrollViewHeight = scrollView.bounds.size.height
				let scrollPosition = scrollView.contentOffset.y + scrollViewHeight
				let threshold = contentHeight - 400
				if scrollPosition >= threshold {
					return .just(())
				} else {
					return .empty()
				}
			}
	}
}

//
//  PostCellViewModel.swift
//  BuyOrNot
//
//  Created by ungQ on 4/24/24.
//

import Foundation
import RxSwift

class PostCellViewModel {
	let postId: String
	var isLiked: BehaviorSubject<Bool> = BehaviorSubject(value: false)
	var isDisliked: BehaviorSubject<Bool> = BehaviorSubject(value: false)

	init(postId: String, isLiked: Bool, isDisliked: Bool) {
		self.postId = postId
		self.isLiked.onNext(isLiked)
		self.isDisliked.onNext(isDisliked)
	}

	func toggleLike() {
		// Logic to toggle like, potentially calling network services and updating `isLiked`
	}

	func toggleDislike() {
		// Logic to toggle dislike
	}
}

//
//  BaseViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import Lottie

class BaseViewController: UIViewController {

	let disposeBag = DisposeBag()

	lazy var loadingLottieView : LottieAnimationView = {

		let animationView = LottieAnimationView(name: "loadingImage")
		animationView.frame = CGRect(x: 0, y: 0,
									 width: 100, height: 100)
		animationView.center = self.view.center
		animationView.contentMode = .scaleAspectFill
		animationView.isHidden = true
		animationView.loopMode = .loop
		animationView.animationSpeed = 2

		return animationView
	}()

	lazy var likeLottieView : LottieAnimationView = {

		let animationView = LottieAnimationView(name: "likeAnimation")
		animationView.frame = CGRect(x: 0, y: 0,
									 width: 200, height: 200)
		animationView.center = self.view.center
		animationView.contentMode = .scaleToFill
		animationView.isHidden = true
		animationView.loopMode = .playOnce
		animationView.animationSpeed = 2
		animationView.backgroundColor = UIColor(white: 1, alpha: 0.4)
		animationView.layer.cornerRadius = 100

		return animationView
	}()


	lazy var dislikeLottieView : LottieAnimationView = {

		let animationView = LottieAnimationView(name: "dislikeAnimation")
		animationView.frame = CGRect(x: 0, y: 0,
									 width: 200, height: 200)
		animationView.center = self.view.center
		animationView.contentMode = .scaleToFill
		animationView.isHidden = true
		animationView.loopMode = .playOnce
		animationView.animationSpeed = 2
		animationView.backgroundColor = UIColor(white: 1, alpha: 0.4)
		animationView.layer.cornerRadius = 100
		
		return animationView
	}()

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = Color.white
		configureLayout()
		bind()
	}

	func bind() {

	}
	
	func configureLayout() {

	}

	@available (*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

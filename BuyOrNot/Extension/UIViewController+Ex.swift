//
//  UIViewController+Ex.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import UIKit


extension UIViewController {
	static func changeRootView(to viewController: UIViewController, isNav: Bool = false) {
		guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
		let sceneDelegate = windowScene.delegate as? SceneDelegate
		let vc = isNav ? UINavigationController(rootViewController: viewController) : viewController
		sceneDelegate?.window?.rootViewController = vc
		sceneDelegate?.window?.makeKey()
	}

	func setNavigationTitleImage() {
		let logo = UIImage(named: "longTitle")
		let imageView = UIImageView(image: logo)

		imageView.contentMode = .scaleAspectFit


		let titleView = UIView()
		titleView.addSubview(imageView)


		imageView.snp.makeConstraints { make in
			make.centerX.centerY.equalTo(titleView)
			make.width.equalTo(132)
			make.height.equalTo(44)
		}

		self.navigationItem.titleView = titleView
		self.navigationController?.navigationBar.backgroundColor = .white


		titleView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width / 2, height: 44)


	}

}

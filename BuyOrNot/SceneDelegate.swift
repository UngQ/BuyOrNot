//
//  SceneDelegate.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?


	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

		let autoLogin = UserDefaultsManager.autoLoginEnabled
//		UserDefaults.standard.bool(forKey: "autoLoginEnabled")

print(autoLogin)

		guard let scene = (scene as? UIWindowScene) else { return }
		window = UIWindow(windowScene: scene)
		window?.tintColor = UIColor.black

		let rootViewController: UIViewController
		if autoLogin {
			rootViewController = UINavigationController(rootViewController: CustomTabBarController())
		} else {
			rootViewController = UINavigationController(rootViewController: SignInViewController())
		}

		window?.rootViewController = rootViewController
		window?.makeKeyAndVisible()
	}

	func sceneDidDisconnect(_ scene: UIScene) {

	}

	func sceneDidBecomeActive(_ scene: UIScene) {

	}

	func sceneWillResignActive(_ scene: UIScene) {

	}

	func sceneWillEnterForeground(_ scene: UIScene) {

	}

	func sceneDidEnterBackground(_ scene: UIScene) {

	}


}


//
//  AppDelegate.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import UIKit
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		IQKeyboardManager.shared.enable = true
		IQKeyboardManager.shared.enableAutoToolbar = true
		IQKeyboardManager.shared.resignOnTouchOutside = true

		


		NotificationCenter.default.addObserver(self, selector: #selector(handleAuthenticationFailure), name: .authenticationFailed, object: nil)

		return true
	}

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

	}

	private var rootViewController: UIViewController? {
		return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController
	}

	@objc private func handleAuthenticationFailure(notification: Notification) {
		DispatchQueue.main.async {
			if let rootVC = self.rootViewController {
				let alert = UIAlertController(title: "로그인 정보 만료", message: "다시 로그인 해주세요", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
					self.changeRootViewToLogin()


				}))
				rootVC.present(alert, animated: true)
			}

		}
	}

	private func changeRootViewToLogin() {
		let loginViewController = SignInViewController()
		changeRootView(loginViewController)
	}

	private func changeRootView(_ viewController: UIViewController, isNav: Bool = false) {
		guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
			  let sceneDelegate = windowScene.delegate as? SceneDelegate else {
			return
		}
		let vc = isNav ? UINavigationController(rootViewController: viewController) : viewController
		sceneDelegate.window?.rootViewController = vc
		sceneDelegate.window?.makeKeyAndVisible()
	}


}

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

		let barAppearance = UINavigationBar.appearance()
		barAppearance.backIndicatorImage = UIImage(systemName: "chevron.backward")  // Set your custom back icon image
		barAppearance.backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.backward")
		UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -200, vertical: 0), for: .default)

	
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


					UIViewController.changeRootView(to: SignInViewController(), isNav: true)
//					changeRootView(SignInViewController(), isNav: true)

				}))
				rootVC.present(alert, animated: true)
			}

		}
	}




}

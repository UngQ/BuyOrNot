//
//  CustomTabbarController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/15/24.
//

import UIKit
import RxSwift
import RxCocoa


class CustomTabBarController: UITabBarController {

	let disposeBag = DisposeBag()

	private let firstVC = UINavigationController(rootViewController: CategoryViewController())
	private let secondVC = UINavigationController(rootViewController: SignInViewController())
	private let thirdVC = UINavigationController(rootViewController: SignUpViewController())

	override func viewDidLoad() {
		super.viewDidLoad()
		self.delegate = self
		setupMiddleButton()

		firstVC.tabBarItem.title = ""
		firstVC.tabBarItem.image = UIImage(systemName: "house.fill")

		secondVC.tabBarItem.title = ""

		thirdVC.tabBarItem.title = ""
		thirdVC.tabBarItem.image = UIImage(systemName: "gearshape.fill")

		viewControllers = [firstVC, UIViewController(), thirdVC]
	}

	func setupMiddleButton() {
		let middleBtn = UIButton(frame: CGRect(x: (self.tabBar.bounds.width / 2) - 35, y: -30, width: 70, height: 70))
		middleBtn.layer.cornerRadius = 35
		middleBtn.backgroundColor = .clear
		middleBtn.setBackgroundImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
		middleBtn.tintColor = .systemGreen


//		middleBtn.addTarget(self, action: #selector(middleButtonAction), for: .touchUpInside)

		self.tabBar.addSubview(middleBtn)
		self.tabBar.layer.masksToBounds = false
		middleBtn.clipsToBounds = true
	}

//	@objc func middleButtonAction(sender: UIButton) {
//		selectedIndex = 2 // 중앙 버튼이면 보통 중앙의 인덱스
//		showActionSheet()
//	}

	func showActionSheet() {
		let actionSheet = UIAlertController(title: .none, message: .none, preferredStyle: .actionSheet)


		let topAction = UIAlertAction(title: "상의 (Top)", style: .default, handler: { _ in
			self.imagePicker()
		})
		let bottomAction = UIAlertAction(title: "바지 (Bottom)", style: .default, handler: { _ in
			self.imagePicker()		})
		let shoesAction = UIAlertAction(title: "신발 (Shoes)", style: .default, handler: { _ in
			self.imagePicker()		})
		let accAction = UIAlertAction(title: "악세사리 (Acc)", style: .default, handler: { _ in
			self.imagePicker()		})
		let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)

		actionSheet.addAction(topAction)
		actionSheet.addAction(bottomAction)
		actionSheet.addAction(shoesAction)
		actionSheet.addAction(accAction)
		actionSheet.addAction(cancelAction)

//		if let popoverController = actionSheet.popoverPresentationController {
//			popoverController.sourceView = sender
//			popoverController.sourceRect = sender.bounds
//		}

		self.present(actionSheet, animated: true, completion: nil)
	}

	func imagePicker() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		   let gallery = UIAlertAction(title: "사진첩", style: .default) { action in

			   let vc = UIImagePickerController()
//				vc.allowsEditing = true
			   vc.delegate = self
			   self.present(vc, animated: true)
		   }
		   let camera = UIAlertAction(title: "카메라", style: .default) { action in

			   let vc = UIImagePickerController()
			   vc.sourceType = .camera
			   self.present(vc, animated: true)
		   }
		   let web = UIAlertAction(title: "네이버", style: .default) { action in

//			   let vc = ImageWebSearchViewController()
//			   vc.valueSpace = {
//				   self.selectedURL = $0
//				   self.selectedImage = nil
//				   self.mainView.optionTableView.reloadRows(at: [IndexPath(row: 0, section: OptionType.image.rawValue)], with: .none)
//			   }
//
//			   self.present(vc, animated: true)

		   }
		   let cancel = UIAlertAction(title: "취소", style: .cancel)

		   alert.addAction(gallery)
		   alert.addAction(camera)
		   alert.addAction(web)
		   alert.addAction(cancel)

		   present(alert, animated: true)
	}
}

extension CustomTabBarController: UITabBarControllerDelegate {
	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		if viewController === viewControllers?[1] {
				 showActionSheet()
				 return false
			 }
			 return true
	}
}

extension CustomTabBarController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true)
	}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

			print(pickedImage.pngData())

			NetworkManager.postImage(query: ImagePostQuery(file: pickedImage.pngData()!))
				.subscribe(onSuccess: { result in
					print(result.files)
				}, onFailure: { error in
					print(error.asAFError?.responseCode)
				})

				.disposed(by: disposeBag)

		}

		dismiss(animated: true)
	}
}

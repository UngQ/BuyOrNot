//
//  CustomTabbarController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/15/24.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation
import IQKeyboardManagerSwift


class CustomTabBarController: UITabBarController {

	let disposeBag = DisposeBag()
	var category = ""

//	private let firstVC = UINavigationController(rootViewController: TotalPostViewController())
//	private let secondVC = UINavigationController(rootViewController: SignInViewController())
//	private let thirdVC = UINavigationController(rootViewController: SignUpViewController())

	private let firstVC = TotalPostViewController()
	private let thirdVC = SignUpViewController()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.delegate = self
		setupMiddleButton()

		firstVC.view.backgroundColor = .white
		firstVC.tabBarItem.title = ""
		firstVC.tabBarItem.image = UIImage(systemName: "house.fill")


		thirdVC.tabBarItem.title = ""
		thirdVC.tabBarItem.image = UIImage(systemName: "gearshape.fill")

		viewControllers = [firstVC, UIViewController(), thirdVC]


		let menuButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: nil)
		self.navigationItem.leftBarButtonItem = menuButton

		// Define the menu actions
		let menuActions = createMenuActions()

		// Attach the menu to the bar button item
		menuButton.menu = UIMenu(title: "", children: menuActions)
		menuButton.primaryAction = nil  // Ensure tapping the button opens the menu
	}

	func createMenuActions() -> [UIMenuElement] {
		let categories = ["전체", "상의", "하의", "신발", "악세사리"]  // ["All", "Tops", "Bottoms", "Shoes", "Accessories"]
		return categories.map { category in
			UIAction(title: category, image: nil, handler: { action in
				// Handle selection
				self.handleCategorySelection(category)
			})
		}
	}

	func handleCategorySelection(_ category: String) {
		print("Selected category: \(category)")
		// Update your UI or perform filtering based on the selected category
	}

	func setupMiddleButton() {
		let middleBtn = UIButton(frame: CGRect(x: (self.tabBar.bounds.width / 2) - 35, y: -20, width: 70, height: 70))
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
			self.category = "#Top"
		})
		let bottomAction = UIAlertAction(title: "바지 (Bottom)", style: .default, handler: { _ in
			self.imagePicker()
			self.category = "#Bottom"
		})
		let shoesAction = UIAlertAction(title: "신발 (Shoes)", style: .default, handler: { _ in
			self.imagePicker()
			self.category = "#Shoes"
		})
		let accAction = UIAlertAction(title: "악세사리 (Acc)", style: .default, handler: { _ in
			self.imagePicker()
			self.category = "#Acc"
		})
		let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)

		actionSheet.addAction(topAction)
		actionSheet.addAction(bottomAction)
		actionSheet.addAction(shoesAction)
		actionSheet.addAction(accAction)
		actionSheet.addAction(cancelAction)

		self.present(actionSheet, animated: true, completion: nil)
	}

	func imagePicker() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let gallery = UIAlertAction(title: "갤러리", style: .default) { action in
			let vc = UIImagePickerController()
			vc.allowsEditing = true
			vc.delegate = self

			self.present(vc, animated: true)
		}
		let camera = UIAlertAction(title: "카메라", style: .default) { action in
			self.openCamera()
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

	func showAlertGoToSetting() {
		let alertController = UIAlertController(
			title: "현재 카메라 사용에 대한 접근 권한이 없습니다.",
			message: "설정 > [살까요?말까요?]탭에서 접근을 활성화 할 수 있습니다.",
			preferredStyle: .alert
		)
		let cancelAlert = UIAlertAction(
			title: "취소",
			style: .cancel
		) { _ in
			alertController.dismiss(animated: true, completion: nil)
		}
		let goToSettingAlert = UIAlertAction(
			title: "설정으로 이동하기",
			style: .default) { _ in
				guard
					let settingURL = URL(string: UIApplication.openSettingsURLString),
					UIApplication.shared.canOpenURL(settingURL)
				else { return }
				UIApplication.shared.open(settingURL, options: [:])
			}
		[cancelAlert, goToSettingAlert]
			.forEach(alertController.addAction(_:))
		DispatchQueue.main.async {
			self.present(alertController, animated: true) // must be used from main thread only
		}
	}

	func openCamera() {
		#if targetEnvironment(simulator)
		fatalError()
		#endif

		// Privacy - Camera Usage Description
		AVCaptureDevice.requestAccess(for: .video) { [weak self] isAuthorized in
			guard isAuthorized else { 
				self?.showAlertGoToSetting()
				return }

			DispatchQueue.main.async {
				  let pickerController = UIImagePickerController()
				  pickerController.sourceType = .camera
				  pickerController.allowsEditing = false
				  pickerController.mediaTypes = ["public.image"]
				  pickerController.delegate = self
				  self?.present(pickerController, animated: true)
				}
		}
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
		if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
			guard let uploadImage = pickedImage.jpegData(compressionQuality: 0.5) else { return }

			NetworkManager.performRequest(route: .uploadImage(query: ImagePostQuery(file: uploadImage)), decodingType: ImageModel.self)
				.subscribe(with: self, onSuccess: { owner, image in
					let vc = UploadPostViewController()
					vc.viewModel.category = owner.category
					vc.viewModel.image = image.files
					print(image.files)
					owner.navigationController?.pushViewController(vc, animated: true)
				})
				.disposed(by: disposeBag)

		}

		dismiss(animated: true)
	}
}

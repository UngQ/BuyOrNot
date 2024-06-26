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


final class CustomTabBarController: UITabBarController {

	let disposeBag = DisposeBag()
	var category = ""
	
	let postVC = PostViewController()
	lazy var firstVC = {
		let vc = postVC
		return UINavigationController(rootViewController: PostViewController())
	}()
	private let thirdVC = UINavigationController(rootViewController: ProfileViewController())

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.navigationController?.isNavigationBarHidden = true
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.navigationController?.isNavigationBarHidden = false
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.delegate = self
		setupMiddleButton()
		setMyProfileViewInTabbar()

		firstVC.view.backgroundColor = .white
		firstVC.tabBarItem.title = ""
		firstVC.tabBarItem.image = UIImage(systemName: "house.fill")

		viewControllers = [firstVC, UIViewController(), thirdVC]

	}

	private func setMyProfileViewInTabbar() {
		NetworkManager.performRequest(route: .myProfile, decodingType: ProfileModel.self)
			.asDriver(onErrorJustReturn: ProfileModel(user_id: "", nick: "", profileImage: nil, followers: [], following: [], posts: []))
			.drive(with: self) { owner, myProfile in

				let endPoint = myProfile.profileImage ?? ""
				let profileImage = "\(APIKey.baseURL.rawValue)/v1/\(endPoint)"
				ImageLoader.loadImage(from: profileImage) { image in

					guard let image = image else { return }
					let circularProfileImage = self.circularImage(from: image, scaledToSize: CGSize(width: 30, height: 30))
					self.thirdVC.tabBarItem = UITabBarItem(title: myProfile.nick, image: circularProfileImage.withRenderingMode(.alwaysOriginal), selectedImage: nil)
				}
			}
			.disposed(by: disposeBag)
	}
	private func circularImage(from originalImage: UIImage, scaledToSize newSize: CGSize) -> UIImage {
		let rect = CGRect(origin: .zero, size: newSize)
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		UIBezierPath(roundedRect: rect, cornerRadius: newSize.width/2).addClip()
		originalImage.draw(in: rect)
		let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return resizedImage ?? originalImage
	}

	private func setupMiddleButton() {
		let middleBtn = UIButton(frame: CGRect(x: (self.tabBar.bounds.width / 2) - 35, y: -20, width: 70, height: 70))
		middleBtn.layer.cornerRadius = 35
		middleBtn.backgroundColor = .clear
		middleBtn.setBackgroundImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
		middleBtn.tintColor = .systemBlue

		self.tabBar.addSubview(middleBtn)
		self.tabBar.layer.masksToBounds = false
		middleBtn.clipsToBounds = true
	}


	private func showActionSheet() {
		let actionSheet = UIAlertController(title: "작성하실 카테고리를 선택해주세요.", message: .none, preferredStyle: .actionSheet)

		let topAction = UIAlertAction(title: Category.top.title, style: .default, handler: { _ in
			self.imagePicker()
			self.category = Category.top.hashTag
		})
		let bottomAction = UIAlertAction(title: Category.bottom.title, style: .default, handler: { _ in
			self.imagePicker()
			self.category = Category.bottom.hashTag
		})
		let shoesAction = UIAlertAction(title: Category.shoes.title, style: .default, handler: { _ in
			self.imagePicker()
			self.category = Category.shoes.hashTag
		})
		let accAction = UIAlertAction(title: Category.acc.title, style: .default, handler: { _ in
			self.imagePicker()
			self.category = Category.acc.hashTag
		})
		let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)

		actionSheet.addAction(topAction)
		actionSheet.addAction(bottomAction)
		actionSheet.addAction(shoesAction)
		actionSheet.addAction(accAction)
		actionSheet.addAction(cancelAction)

		self.present(actionSheet, animated: true, completion: nil)
	}

	private func imagePicker() {

		let alert = UIAlertController(title: "이미지 선택", message: nil, preferredStyle: .actionSheet)
		let gallery = UIAlertAction(title: "갤러리", style: .default) { action in
			let vc = UIImagePickerController()
			vc.allowsEditing = true
			vc.delegate = self

			vc.modalPresentationStyle = .fullScreen
			self.present(vc, animated: true)
		}
		let camera = UIAlertAction(title: "카메라", style: .default) { action in
			self.openCamera()
		}

		let cancel = UIAlertAction(title: "취소", style: .cancel)

		alert.addAction(gallery)
		alert.addAction(camera)
		alert.addAction(cancel)

		present(alert, animated: true)
	}

	private func showAlertGoToSetting() {
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
			self.present(alertController, animated: true)
		}
	}

	private func openCamera() {
		#if targetEnvironment(simulator)
		fatalError()
		#endif

		AVCaptureDevice.requestAccess(for: .video) { [weak self] isAuthorized in
			guard isAuthorized else { 
				self?.showAlertGoToSetting()
				return }

			DispatchQueue.main.async {
				  let pickerController = UIImagePickerController()
				  pickerController.sourceType = .camera
				  pickerController.allowsEditing = true
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

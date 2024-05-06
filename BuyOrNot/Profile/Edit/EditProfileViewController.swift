//
//  EditProfileViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 5/2/24.
//

import UIKit
import RxSwift
import RxCocoa

final class EditProfileViewController: BaseViewController {


	let viewModel = EditProfileViewModel()

	private let profileImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = 100
		imageView.backgroundColor = .lightGray
		imageView.isUserInteractionEnabled = true
		imageView.layer.borderColor = UIColor.systemBlue.cgColor
		imageView.layer.borderWidth = 5
		return imageView
	}()

	private let nicknameTextField: UITextField = {
		let textField = UITextField()
		textField.borderStyle = .roundedRect
		return textField
	}()

	let descriptionLabel = UILabel()


	private let saveButton = PointButton(title: "저장")

	private let imagePicker = UIImagePickerController()

	let navigationRightButton = UIButton()


	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupConstraints()
		setupActions()
		view.backgroundColor = .white

	
		setNavigationTitleImage()

		let profileImage = "\(APIKey.baseURL.rawValue)/v1/\(viewModel.profileData.value.profileImage ?? "")"
		profileImageView.loadImage(from: profileImage)
		nicknameTextField.text = viewModel.profileData.value.nick

		navigationRightButton.setBackgroundImage(UIImage(systemName: "person.slash.fill"), for: .normal)
		navigationRightButton.layer.cornerRadius = 15
		navigationRightButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
		navigationRightButton.tintColor = .systemRed
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navigationRightButton)

		self.nicknameTextField.becomeFirstResponder()
		if let endPosition = self.nicknameTextField.position(from: self.nicknameTextField.endOfDocument, offset: 0) {
			self.nicknameTextField.selectedTextRange = self.nicknameTextField.textRange(from: endPosition, to: endPosition)
		}



	}

	private func promptForDeletion() {
		let alert = UIAlertController(title: "계정 탈퇴 확인", message: "비밀번호를 입력하세요", preferredStyle: .alert)
		alert.addTextField { textField in
			textField.placeholder = "비밀번호 입력"
			textField.isSecureTextEntry = true
		}
		let action = UIAlertAction(title: "확인", style: .destructive) { [unowned self] _ in
			guard let password = alert.textFields?.first?.text,
				  let savedPassword = UserDefaults.standard.string(forKey: "password"),
				  password == savedPassword else {
				self.showMismatchError()
				return
			}
			self.viewModel.deleteTrigger.accept(())
		}
		alert.addAction(action)
		alert.addAction(UIAlertAction(title: "취소", style: .cancel))
		present(alert, animated: true)
	}

	private func showMismatchError() {
		 let alert = UIAlertController(title: "오류", message: "비밀번호가 일치하지 않습니다.", preferredStyle: .alert)
		 alert.addAction(UIAlertAction(title: "확인", style: .default))
		 present(alert, animated: true)
	 }

	override func bind() {
		let confirmDeleteTapped = PublishSubject<Void>()


		let input = EditProfileViewModel.Input(nicknameText: nicknameTextField.rx.text.orEmpty,
											   saveButtonTapped: confirmDeleteTapped.asObservable())


		let output = viewModel.transform(input: input)

		output.isValidation
			.drive(with: self) { owner, valid in
				owner.descriptionLabel.isHidden = valid
				owner.nicknameTextField.layer.borderColor = valid ? UIColor.systemBlue.cgColor : UIColor.systemRed.cgColor
				owner.saveButton.isEnabled = valid
				owner.saveButton.backgroundColor = valid ? .systemBlue : .lightGray
			}
			.disposed(by: disposeBag)

		saveButton.rx.tap.asDriver()
			.drive(with: self) { owner, _ in
				owner.showAlert {
					confirmDeleteTapped.onNext(())
				}
			}
			.disposed(by: disposeBag)


		output.deleteResult
			.drive(with: self) { owner, _ in
				
				owner.view.makeToast("그동안 이용해주셔서 감사합니다.😢", position: .center, title: "회원탈퇴가 완료되었습니다.")


				let vc = SignInViewController()
				vc.viewModel.handleAutoLogin("", password: "", enable: false)

				DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
					UIViewController.changeRootView(to: vc, isNav: true)
				}

			}
			.disposed(by: disposeBag)

		output.successTrigger
			.drive(with: self) { owner, _ in
				EditProfileViewController.changeRootView(to: CustomTabBarController(), isNav: true)
			}
			.disposed(by: disposeBag)

		navigationRightButton.rx.tap
			.bind(with: self) { owner, _ in
				owner.promptForDeletion()
			}
			.disposed(by: disposeBag)
	}

	func showAlert(completionHandler: @escaping () -> Void) {
		let alert = UIAlertController(title: "프로필 변경", message: "프로필 정보를 변경하시겠습니까?", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { _ in

			completionHandler()

		}))
		present(alert, animated: true, completion: nil)
	}

	

	private func setupViews() {
		view.addSubview(profileImageView)
		view.addSubview(nicknameTextField)
		view.addSubview(saveButton)
		view.addSubview(descriptionLabel)

		saveButton.backgroundColor = .systemBlue

		descriptionLabel.text = "3~10자, 공백, 자음, 모음 불가"
		descriptionLabel.font = .boldSystemFont(ofSize: 14)
		descriptionLabel.textColor = .systemRed
	}

	private func setupConstraints() {
		profileImageView.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
			make.size.equalTo(200)
		}

		nicknameTextField.snp.makeConstraints { make in
			make.top.equalTo(profileImageView.snp.bottom).offset(20)
			make.height.equalTo(50)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}
		descriptionLabel.snp.makeConstraints { make in
			make.height.equalTo(24)
			make.top.equalTo(nicknameTextField.snp.bottom).offset(5)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
		}

		saveButton.snp.makeConstraints { make in
			make.top.equalTo(descriptionLabel.snp.bottom).offset(5)
			make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
			make.height.equalTo(50)
		}
	}

	private func setupActions() {

		profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(promptForPhoto)))
		imagePicker.delegate = self
	}


	@objc private func promptForPhoto() {
		let alert = UIAlertController(title: "프로필 사진 변경", message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "갤러리에서 선택", style: .default, handler: { _ in self.openGallery() }))
		alert.addAction(UIAlertAction(title: "기본 프로필 이미지", style: .default, handler: { _ in self.settingDefaultProfileImage() }))
		alert.addAction(UIAlertAction(title: "취소", style: .cancel))
		present(alert, animated: true)
	}

	private func settingDefaultProfileImage() {
		let defaultImage = UIImage(systemName: "person.circle.fill")
		let uploadImage = defaultImage?.jpegData(compressionQuality: 1.0)
		profileImageView.image = defaultImage
		viewModel.profileImage = uploadImage
	}

	private func openGallery() {
		let vc = UIImagePickerController()
		vc.allowsEditing = true
		vc.delegate = self

		vc.modalPresentationStyle = .fullScreen
		self.present(vc, animated: true)
	}


}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
			guard let uploadImage =
					pickedImage.jpegData(compressionQuality: 0.5) else { return }

			profileImageView.image = pickedImage
			viewModel.profileImage = uploadImage

		}
		dismiss(animated: true)
	}
}

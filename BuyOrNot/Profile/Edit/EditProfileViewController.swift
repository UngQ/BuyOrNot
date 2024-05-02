//
//  EditProfileViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 5/2/24.
//

import UIKit
import RxSwift
import RxCocoa

class EditProfileViewController: BaseViewController {


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



		output.successTrigger
			.drive(with: self) { owner, _ in
				EditProfileViewController.changeRootView(to: CustomTabBarController(), isNav: true)
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

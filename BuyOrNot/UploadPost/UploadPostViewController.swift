//
//  UploadPostViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/16/24.
//

import UIKit
import SnapKit
import Kingfisher
import Alamofire

class UploadPostViewController: BaseViewController {

	let viewModel = UploadPostViewModel()

	let scrollView = UIScrollView()
	let contentView = UIView()

	let imageView = UIImageView()
	let titleTextField = SignTextField(placeholderText: "브랜드나 상품명을 입력해주세요")
	let priceTextField = SignTextField(placeholderText: "가격을 입력해주세요")
	let postButton = PointButton(title: "평가받기")




    override func viewDidLoad() {
        super.viewDidLoad()

		setNavigationTitleImage()
    }

	override func bind() {
		let input = UploadPostViewModel.Input(
			titleText: titleTextField.rx.text.orEmpty,
											  priceText: priceTextField.rx.text.orEmpty,
			postButtonClicked: postButton.rx.tap)

		let output = viewModel.transform(input: input)

		output.formattedPrice
			.drive(with: self, onNext: { owner, price in
				owner.priceTextField.text = price
			})
			.disposed(by: disposeBag)

		output.valid
			.drive(with: self) { owner, valid in
				owner.postButton.backgroundColor = valid ? .systemBlue : .lightGray
				owner.postButton.isEnabled = valid
			}
			.disposed(by: disposeBag)

		output.isPostCompleted
			.drive(with: self) { owner, result in
				if result {
					UIViewController.changeRootView(to: CustomTabBarController(), isNav: true)

				}
			}
			.disposed(by: disposeBag)

		

	}

	override func configureLayout() {
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)
		contentView.addSubview(imageView)
		contentView.addSubview(titleTextField)
		contentView.addSubview(priceTextField)
		contentView.addSubview(postButton)

		scrollView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}

		contentView.snp.makeConstraints { make in
			make.verticalEdges.equalTo(scrollView)
			make.width.equalTo(scrollView.snp.width)
			make.bottom.equalTo(postButton.snp.bottom)
		}

		imageView.snp.makeConstraints { make in
			make.top.equalTo(contentView)
			make.horizontalEdges.equalToSuperview()
			make.height.equalTo(imageView.snp.width)
		}

		titleTextField.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(imageView.snp.bottom).offset(20)
			make.horizontalEdges.equalTo(contentView).inset(20)
		}

		priceTextField.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(titleTextField.snp.bottom).offset(20)
			make.horizontalEdges.equalTo(contentView).inset(20)
		}

		postButton.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.top.equalTo(priceTextField.snp.bottom).offset(20)
			make.horizontalEdges.equalTo(contentView).inset(20)
		}
		titleTextField.clearButtonMode = .whileEditing
		priceTextField.delegate = self
		priceTextField.keyboardType = .numberPad
		priceTextField.clearButtonMode = .whileEditing


		scrollView.isScrollEnabled = true
		imageView.contentMode = .scaleAspectFit


		let image = "\(APIKey.baseURL.rawValue)/v1/\(viewModel.image[0])"
		self.imageView.loadImage(from: image)


	}


}

extension UploadPostViewController: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if textField == priceTextField {
				   return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
			   }
			   return true
	}

}

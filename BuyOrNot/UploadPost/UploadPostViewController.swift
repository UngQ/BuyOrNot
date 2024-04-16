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

	let imageView = UIImageView()

	var category = ""
	var image = [""]

    override func viewDidLoad() {
        super.viewDidLoad()

		print(viewModel.category)
		print(viewModel.image)
    }
    

	override func configureLayout() {
		view.addSubview(imageView)

		imageView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide)
			make.horizontalEdges.equalToSuperview()
			make.height.equalTo(imageView.snp.width)
		}

		imageView.contentMode = .scaleAspectFit

		NetworkManager.performRequest(route: .lookImage(endPoint: image[0]), decodingType: (Data).self)
			.subscribe(with: self) { owner, data in
				if let image = UIImage(data: data) {
					print(data)
					owner.imageView.image = image
				}
			}
			.disposed(by: disposeBag)

//		let urlRequest = Router.lookImage(endPoint: image[0])
//		AF.request(urlRequest)
//			.responseData { response in
//				switch response.result {
//
//				case .success(let data):
//					if let image = UIImage(data: data) {
//						self.imageView.image = image
//					}
//				case .failure(let error):
//					print(error)
//				}
//			}
	}

}

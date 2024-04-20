//
//  ContentPostViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/18/24.
//

import UIKit
import RxSwift
import RxCocoa

class ContentPostViewController: BaseViewController {


	lazy var viewModel = ContentPostViewModel()

	private lazy var imageCollectionView: UICollectionView = {
			let layout = UICollectionViewFlowLayout()
		let width = view.bounds.width / 3
			layout.itemSize = CGSize(width: width, height: width) // 셀 크기 조정
			layout.minimumLineSpacing = 0
			layout.minimumInteritemSpacing = 0
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
			collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.id)
//			collectionView.delegate = self
//			collectionView.dataSource = self
			return collectionView
		}()

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.viewModel.viewWillAppearTrigger.accept(())


	}

    override func viewDidLoad() {
        super.viewDidLoad()


		


    }

	override func bind() {
		let input = ContentPostViewModel.Input()

		let output = viewModel.transform(input: input)

		output.data.drive(imageCollectionView.rx.items(cellIdentifier: ImageCollectionViewCell.id, cellType: ImageCollectionViewCell.self)) {
			row, element, cell in


			let postImage = "\(APIKey.baseURL.rawValue)/v1/\(element.files[0])"
			cell.imageView.loadImage(from: postImage)
			}
		.disposed(by: disposeBag)


	}

	override func configureLayout() {
		view.addSubview(imageCollectionView)

		imageCollectionView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}

		imageCollectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.id)

		imageCollectionView.backgroundColor = .brown
	}


}



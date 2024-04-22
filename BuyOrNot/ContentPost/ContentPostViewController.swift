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
		let layout = UICollectionViewFlowLayout.createThreeColumnFlowLayout(in: self.view)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.id)
		collectionView.refreshControl = refreshControl
		return collectionView
	}()
	private let refreshControl = UIRefreshControl()


	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		reloadData()

	}

	@objc func reloadData() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
			self.viewModel.isLoading = false
			self.viewModel.nextCursor = nil
			self.viewModel.viewWillAppearTrigger.accept(())
			self.refreshControl.endRefreshing()
		}

	}

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.title = viewModel.title


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

		imageCollectionView.rx.itemSelected
			.asDriver()
			.drive(with: self) { owner, index in
				let vc = PostViewController()
				vc.TotalOrDetail = false
				vc.viewModel.id = owner.viewModel.postsData.value[index.row].post_id
				vc.viewModel.totalOrDetail = false
				owner.navigationController?.pushViewController(vc, animated: true)

			}
			.disposed(by: disposeBag)


		imageCollectionView.rx.reachedBottom
			.skip(1)
			.subscribe(with: self) { owner, position in
		 print("HHHHH")
				owner.viewModel.isLoading = true
				owner.viewModel.viewWillAppearTrigger.accept(())
			}
			.disposed(by: disposeBag)

		output.cautionMessage
			.drive(with: self) { owner, message in
				owner.view.makeToast(message, position: .center)
			}
			.disposed(by: disposeBag)


	}

	override func configureLayout() {
		view.addSubview(imageCollectionView)

		imageCollectionView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}


		imageCollectionView.backgroundColor = .brown

		refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)

	}


}




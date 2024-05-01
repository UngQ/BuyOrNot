//
//  ContentPostViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/18/24.
//

import UIKit
import RxSwift
import RxCocoa

protocol ContentPostViewControllerDelegate: AnyObject {
	func didSelectItem(index: Int)
	func didScrollTableView(_ direction: ScrollDirection)
}

enum ScrollDirection {
	case up
	case down
}

class ContentPostViewController: BaseViewController {


	lazy var viewModel = ContentPostViewModel()

	weak var contentPostVCDelegate: ContentPostViewControllerDelegate?


	private lazy var imageCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout.createCompositionLayout(in: self.view)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout ?? UICollectionViewFlowLayout())
		collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.id)
		collectionView.refreshControl = refreshControl
		return collectionView
	}()
	var collectionViewLayout: UICollectionViewLayout?

	let emptyLabel = {
		let view = UILabel()
		view.text = "아직 게시글이 없습니다."
		view.font = .boldSystemFont(ofSize: 16)
		view.textAlignment = .center
		return view
	}()

	private let refreshControl = UIRefreshControl()


	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)


	}

	@objc func reloadData() {
		self.loadingLottieView.isHidden = false
		self.loadingLottieView.play()
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
			self.viewModel.isLoading = false
			self.viewModel.nextCursor = nil
			self.viewModel.viewWillAppearTrigger.accept(())

		}



	}

	override func viewDidLoad() {
		super.viewDidLoad()
		reloadData()

		navigationItem.title = viewModel.title

		loadingLottieView.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.size.equalTo(100)
		}

	}

	override func bind() {
		let input = ContentPostViewModel.Input()

		let output = viewModel.transform(input: input)

		output.data.drive(imageCollectionView.rx.items(cellIdentifier: ImageCollectionViewCell.id, cellType: ImageCollectionViewCell.self)) { [weak self]
			row, element, cell in


			let postImage = "\(APIKey.baseURL.rawValue)/v1/\(element.files[0])"
			cell.imageView.loadImage(from: postImage)


			DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in 
				self?.refreshControl.endRefreshing()
				self?.loadingLottieView.isHidden = true
				self?.loadingLottieView.stop()
			}
		}
		.disposed(by: disposeBag)

		output.data
			.drive(with: self) { owner, comments in
				if comments == [] {
					owner.emptyLabel.isHidden = false
					owner.loadingLottieView.isHidden = true
					owner.loadingLottieView.stop()

				} else {
					owner.emptyLabel.isHidden = true
				}
			}
			.disposed(by: disposeBag)





		imageCollectionView.rx.itemSelected
			.asDriver()
			.drive(with: self) { owner, index in

				if owner.contentPostVCDelegate != nil {
					owner.contentPostVCDelegate?.didSelectItem(index: index.row)

				} else {

					let vc = PostViewController()
					vc.viewModel.id = owner.viewModel.postsData.value[index.row].post_id
					vc.viewModel.totalOrDetail = false
					owner.navigationController?.pushViewController(vc, animated: true)
				}
			}
			.disposed(by: disposeBag)


		imageCollectionView.rx.reachedBottom
			.skip(1)
			.subscribe(with: self) { owner, position in
		 print("HHHHH")
				owner.loadingLottieView.isHidden = false
				owner.loadingLottieView.play()
				owner.viewModel.isLoading = true
				owner.viewModel.viewWillAppearTrigger.accept(())
			}
			.disposed(by: disposeBag)

		output.cautionMessage
			.drive(with: self) { owner, message in
				owner.loadingLottieView.isHidden = true
				owner.loadingLottieView.stop()
				owner.view.makeToast(message, position: .center)
			}
			.disposed(by: disposeBag)

		setupScrollBinding()

	}

	func setupScrollBinding() {
		  imageCollectionView.rx.didScroll
			  .map { [weak self] in
				  self?.imageCollectionView.panGestureRecognizer.translation(in: self?.imageCollectionView.superview)
			  }
			  .distinctUntilChanged() // 중복 값 필터링
			  .compactMap { $0 }
			  .subscribe(onNext: { [weak self] translation in
				  if translation.y > 0 {
					  self?.contentPostVCDelegate?.didScrollTableView(.down)
				  } else if translation.y < 0 {
					  self?.contentPostVCDelegate?.didScrollTableView(.up)
				  }
			  })
			  .disposed(by: disposeBag)
	  }

	override func configureLayout() {
		view.addSubview(imageCollectionView)
		view.addSubview(loadingLottieView)
		view.addSubview(emptyLabel)

		imageCollectionView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}

		emptyLabel.snp.makeConstraints { make in
			make.centerY.centerX.equalToSuperview()
		}

		refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
		refreshControl.alpha = 0


	}


}



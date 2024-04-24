//
//  TotalPostViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import Lottie



class PostViewController: BaseViewController {

	var TotalOrDetail = true

	let viewModel = PostViewModel()

	private var currentCategory = "전체"
	let tableView = UITableView()
	private let refreshControl = UIRefreshControl()

	lazy var loadingLottieView : LottieAnimationView = {

		let animationView = LottieAnimationView(name: "loadingImage")
		animationView.frame = CGRect(x: 0, y: 0,
									 width: 100, height: 100)
		animationView.center = self.view.center
		animationView.contentMode = .scaleAspectFill
		animationView.isHidden = true
		animationView.loopMode = .loop
		animationView.animationSpeed = 2

		return animationView
	}()

	lazy var likeLottieView : LottieAnimationView = {

		let animationView = LottieAnimationView(name: "likeAnimation")
		animationView.frame = CGRect(x: 0, y: 0,
									 width: 500, height: 500)
		animationView.center = self.view.center
		animationView.contentMode = .scaleToFill
		animationView.isHidden = true
		animationView.loopMode = .playOnce
		animationView.animationSpeed = 2

		return animationView
	}()


	lazy var dislikeLottieView : LottieAnimationView = {

		let animationView = LottieAnimationView(name: "dislikeAnimation")
		animationView.frame = CGRect(x: 0, y: 0,
									 width: 500, height: 500)
		animationView.center = self.view.center
		animationView.contentMode = .scaleToFill
		animationView.isHidden = true
		animationView.loopMode = .playOnce
		animationView.animationSpeed = 2

		return animationView
	}()

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		reloadData()
	}

	@objc func reloadData() {
		self.refreshControl.endRefreshing()
		self.loadingLottieView.isHidden = false
		self.loadingLottieView.play()
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
			
			self.viewModel.isLoading = false
			self.viewModel.nextCursor = nil
			self.viewModel.viewWillAppearTrigger.accept(())


			}

	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}

    override func viewDidLoad() {
        super.viewDidLoad()



		if TotalOrDetail {

			setNavigationTitleImage()

			setupInteractiveTitleAsLeftBarButtonItem()

		} else {
			self.navigationItem.title = "게시물"
		}

	}


	func setupInteractiveTitleAsLeftBarButtonItem() {
		let titleButton = UIButton(type: .system)
		titleButton.setTitle("최근 게시물 ▼", for: .normal)
		titleButton.addTarget(self, action: #selector(titleButtonTapped), for: .touchUpInside)

		let categories = [Category.top,
						  Category.bottom,
						  Category.shoes,
						  Category.acc]
		let actions = categories.map { category -> UIAction in
			UIAction(title: category.title, handler: { _ in
				self.handleCategorySelection(category)
			})
		}
		let menu = UIMenu(title: "Category", children: actions)
		titleButton.menu = menu
		titleButton.showsMenuAsPrimaryAction = true
		navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleButton)
	}

	@objc func titleButtonTapped() {
		// 메뉴 보여줄 필요 없음, 자동으로 보여짐
	}

	func handleCategorySelection(_ category: Category) {
		print("Selected category: \(category)")
		let vc = ContentPostViewController()
		vc.viewModel.title = category.title
		vc.viewModel.hashTag = category.rawValue

		navigationController?.pushViewController(vc, animated: true)
	}
//	func createMenuActions() -> [UIMenuElement] {
//		let categories = [Category.top,
//						  Category.bottom,
//						  Category.shoes,
//						  Category.acc]
//
//		return categories.map { category in
//			UIAction(title: category.title, image: nil, handler: { action in
//
//				self.handleCategorySelection(category)
//			})
//		}
//	}

//	func handleCategorySelection(_ category: Category) {
//		print("Selected category: \(category)")
//		let vc = ContentPostViewController()
//		vc.viewModel.title = category.title
//		vc.viewModel.hashTag = category.rawValue
//		
//		navigationController?.pushViewController(vc, animated: true)
//
//	}


	

override func bind() {
	let likeButtonTapped = PublishSubject<Int>()
	let disLikeButtonTapped = PublishSubject<Int>()

	let input = PostViewModel.Input(
		likeButtonTap: likeButtonTapped.asObservable(),
										 disLikeButtonTap: disLikeButtonTapped.asObservable())

	let output = viewModel.transform(input: input)


	output.data
		.drive(tableView.rx.items(cellIdentifier: PostTableViewCell.id, cellType: PostTableViewCell.self)) {
			row, element, cell in
			cell.selectionStyle = .none
			print("\(row) 여기가 언제 실행되는가")

			guard let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) else {
				return
			}
			cell.like = element.likes.contains(myId)
			cell.dislike = element.likes2.contains(myId)

			print(cell.like, cell.dislike)

			self.configureVisibility(of: cell, show: cell.like || cell.dislike)



			//셀 프로필 이미지
			if let endPoint = element.creator.profileImage {
				let profileImage = "\(APIKey.baseURL.rawValue)/v1/\(endPoint)"
				cell.profileImageView.loadImage(from: profileImage)
			} 


			//셀 작성자 이름
			cell.usernameLabel.text = element.creator.nick

			//좋아요/싫어요 진행바
			let totalVotes = max(element.likes.count + element.likes2.count, 1) // Avoid division by zero
			let likeRatio = Float(element.likes.count) / Float(totalVotes)


			if element.likes.count == 0 && element.likes2.count == 0 {
				cell.likeDislikeProgressView.trackTintColor = .lightGray
				cell.likeDislikeProgressView.setProgress(0, animated: false)

			} else {
				
				cell.likeDislikeProgressView.trackTintColor = .systemRed
				cell.likeDislikeProgressView.setProgress(likeRatio, animated: false)
			}




			//셀 포스트 이미지
			let postImage = "\(APIKey.baseURL.rawValue)/v1/\(element.files[0])"
			cell.postImageView.loadImage(from: postImage)

			cell.titleNPriceLabel.text = "\(element.title) / \(element.content1)"
			cell.likeLabel.text = "사세요 \(element.likes.count)개"
			cell.dislikeLabel.text = "마세요 \(element.likes2.count)개"
			cell.timeLabel.text = element.createdAt.formattedDate()

			if cell.like {
				cell.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
			} else {
				cell.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
			}

			if cell.dislike {
				cell.dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
			} else {
				cell.dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
			}

//
//			cell.leftTap = {
//				likeButtonTapped.onNext(row)
//			}
//			cell.rightTap = {
//				disLikeButtonTapped.onNext(row)
//			}
//
			cell.likeButton.rx.tap
				.map { row }
				.bind(to: likeButtonTapped)
				.disposed(by: cell.disposeBag)


			cell.dislikeButton.rx.tap
				.map { row }
				.bind(to: disLikeButtonTapped)
				.disposed(by: cell.disposeBag)


			likeButtonTapped
				.subscribe(onNext: { index in

						cell.playLikeAnimation()

					})
				 .disposed(by: cell.disposeBag)

			disLikeButtonTapped
				.subscribe(onNext: { index in
					if !cell.like && !cell.dislike {
						self.dislikeLottieView.isHidden = false
						self.dislikeLottieView.play(completion: { completed in
							print("다시 트루")
							self.dislikeLottieView.isHidden = true
						})
					}})
				 .disposed(by: cell.disposeBag)

			cell.commentButton.rx.tap
				.asDriver()
				.drive(with: self) { owner, _ in
					let vc = CommentViewController()
					vc.viewModel.postID = element.post_id

					let nav = UINavigationController(rootViewController: vc)
					owner.present(nav, animated: true)
				}
				.disposed(by: cell.disposeBag)


			DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {

				self.loadingLottieView.isHidden = true
				self.loadingLottieView.stop()
			}

		}

		.disposed(by: disposeBag)

	tableView.rx.reachedBottom
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
			owner.view.makeToast(message, position: .center)
		}
		.disposed(by: disposeBag)

	}

	func configureVisibility(of cell: PostTableViewCell, show: Bool) {
		if show {
			// 보이기 전에 뷰를 투명하게 만듭니다.
			cell.likeDislikeProgressView.alpha = 0.0
			cell.likeLabel.alpha = 0.0
			cell.dislikeLabel.alpha = 0.0
			cell.likeDislikeProgressView.isHidden = false
			cell.likeLabel.isHidden = false
			cell.dislikeLabel.isHidden = false

			// 애니메이션으로 뷰를 서서히 나타나게 합니다.
			UIView.animate(withDuration: 0.3) {
				cell.likeDislikeProgressView.alpha = 1.0
				cell.likeLabel.alpha = 1.0
				cell.dislikeLabel.alpha = 1.0
			}
		} else {
			// 숨기기 전에 뷰가 보이도록 합니다.
			UIView.animate(withDuration: 0.3, animations: {
				cell.likeDislikeProgressView.alpha = 0.0
				cell.likeLabel.alpha = 0.0
				cell.dislikeLabel.alpha = 0.0
			}) { completed in
				if completed {
					cell.likeDislikeProgressView.isHidden = true
					cell.likeLabel.isHidden = true
					cell.dislikeLabel.isHidden = true
				}
			}
		}
	}

	override func configureLayout() {
		view.addSubview(tableView)
		view.addSubview(loadingLottieView)
		view.addSubview(likeLottieView)
		view.addSubview(dislikeLottieView)

		

		tableView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide)
			make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
		}

		tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.id)
		tableView.refreshControl = refreshControl
		refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
		refreshControl.alpha = 0

	}
}

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
import RxGesture


class PostViewController: BaseViewController {

	var TotalOrDetail = true

	let viewModel = PostViewModel()

	private var currentCategory = "전체"
	let tableView = UITableView()
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

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		reloadData()


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


	func handleCategorySelection(_ category: Category) {
		print("Selected category: \(category)")
		let vc = ContentPostViewController()
		vc.collectionViewLayout = UICollectionViewFlowLayout.createCompositionLayout(in: self.view)
		vc.viewModel.title = category.title
		vc.viewModel.hashTag = category.rawValue
		vc.viewModel.content = .categoryPosts

		navigationController?.pushViewController(vc, animated: true)
	}


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

			if myId == element.creator.user_id {
				cell.deleteButton.isHidden = false
			} else {
				cell.deleteButton.isHidden = true
			}

			cell.like = element.likes.contains(myId)
			cell.dislike = element.likes2.contains(myId)

			print(cell.like, cell.dislike)

			//셀 프로필 이미지
			if let endPoint = element.creator.profileImage {
				let profileImage = "\(APIKey.baseURL.rawValue)/v1/\(endPoint)"
				cell.profileImageView.loadImage(from: profileImage)
			} 


			//셀 작성자 이름
			cell.usernameLabel.text = element.creator.nick

			//좋아요/싫어요 진행바
			let totalVotes = max(element.likes.count + element.likes2.count, 1)
			let likeRatio = Float(element.likes.count) / Float(totalVotes)


			if element.likes.contains(myId) || element.likes2.contains(myId) {
				cell.likeDislikeProgressView.isHidden = false
				cell.likeLabel.isHidden = false
				cell.dislikeLabel.isHidden = false
				cell.likeDislikeProgressView.trackTintColor = .systemRed
				cell.likeDislikeProgressView.setProgress(likeRatio, animated: false)
				cell.likeDislikeProgressView.snp.remakeConstraints { make in
					make.top.equalTo(cell.postImageView.snp.bottom).offset(5)
					make.left.right.equalToSuperview().inset(10)
					make.height.equalTo(32)
				}
			} else {
				cell.likeDislikeProgressView.snp.remakeConstraints { make in
					make.top.equalTo(cell.postImageView.snp.bottom).offset(5)
					make.left.right.equalToSuperview().inset(10)
					make.height.equalTo(0)
				}
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

			cell.likeButton.rx.tap
				.map { row }
				.bind(to: likeButtonTapped)
				.disposed(by: cell.disposeBag)


			cell.dislikeButton.rx.tap
				.map { row }
				.bind(to: disLikeButtonTapped)
				.disposed(by: cell.disposeBag)

			cell.postImageView.rx.tapGesture(configuration: { gestureRecognizer, delegate in
				gestureRecognizer.numberOfTapsRequired = 2 })
			.when(.recognized)
			.subscribe(onNext: { [weak self] gesture in
				guard let strongSelf = self else { return }
				let touchPoint = gesture.location(in: gesture.view)
				if let width = gesture.view?.bounds.width {
					if touchPoint.x < width / 2 {
						likeButtonTapped.onNext(row)
						self?.playAppropriateAnimation(for: "like", likeCondition: cell.like, dislikeCondition: cell.dislike)
					} else {
						disLikeButtonTapped.onNext(row)
						self?.playAppropriateAnimation(for: "dislike", likeCondition: cell.like, dislikeCondition: cell.dislike)
					}
				}
			})
			.disposed(by: cell.disposeBag)



			cell.profileImageView.rx.tapGesture()
				.when(.recognized)
				.bind(with: self) { owner, gesture in
					let vc = ProfileViewController()

					if element.creator.user_id == myId {
						
						owner.navigationController?.pushViewController(vc, animated: true)
					} else {
						vc.viewModel.myOrOther = false
						vc.viewModel.othersId = element.creator.user_id
						vc.tabmanVC.myOrOthers = false
						vc.tabmanVC.myPostsVC.viewModel.myId = element.creator.user_id
						owner.navigationController?.pushViewController(vc, animated: true)
					}
				}
				.disposed(by: cell.disposeBag)

			cell.usernameLabel.rx.tapGesture()
				.when(.recognized)
				.bind(with: self) { owner, gesture in
					let vc = ProfileViewController()

					if element.creator.user_id == myId {
						owner.navigationController?.pushViewController(vc, animated: true)
					} else {
						vc.viewModel.myOrOther = false
						vc.viewModel.othersId = element.creator.user_id
						vc.tabmanVC.myOrOthers = false
						vc.tabmanVC.myPostsVC.viewModel.myId = element.creator.user_id
						owner.navigationController?.pushViewController(vc, animated: true)
					}
				}
				.disposed(by: cell.disposeBag)

			cell.likeButton.rx.tap
				.subscribe(onNext: { [weak self]  index in

					self?.playAppropriateAnimation(for: "like", likeCondition: cell.like, dislikeCondition: cell.dislike)
				})
				 .disposed(by: cell.disposeBag)

			cell.dislikeButton.rx.tap
				.subscribe(onNext: { [weak self] index in
					print(cell.like, cell.dislike)
					self?.playAppropriateAnimation(for: "dislike", likeCondition: cell.like, dislikeCondition: cell.dislike)
					})
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
				self.refreshControl.endRefreshing()

				self.loadingLottieView.isHidden = true
				self.loadingLottieView.stop()
			}

		}

		.disposed(by: disposeBag)

	if TotalOrDetail {
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
	}
	
	output.cautionMessage
		.drive(with: self) { owner, message in
			owner.view.makeToast(message, position: .center)
		}
		.disposed(by: disposeBag)



	}


	func playAppropriateAnimation(for type: String, likeCondition: Bool, dislikeCondition: Bool) {
//		guard !likeCondition && !dislikeCondition else { return }
		switch type {
		case "like":
			if !likeCondition {
			likeLottieView.isHidden = false
				likeLottieView.play { [weak self] completed in
					print("Animation completed")
					self?.likeLottieView.isHidden = true
				}
			}
		case "dislike":
			if !dislikeCondition {
			dislikeLottieView.isHidden = false
				dislikeLottieView.play { [weak self] completed in
					print("Animation completed")
					self?.dislikeLottieView.isHidden = true
				}
			}
		default:
			break
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

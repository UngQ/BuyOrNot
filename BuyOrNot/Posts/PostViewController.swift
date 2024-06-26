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
import iamport_ios
import WebKit


final class PostViewController: BaseViewController {

	let viewModel = PostViewModel()

	private var currentCategory = "전체"
	let tableView = UITableView()
	private let refreshControl = UIRefreshControl()

	private let messageListButton = UIButton()

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

		if viewModel.totalOrDetail {
			setNavigationTitleImage()
			setupInteractiveTitleAsLeftBarButtonItem()
			setupMessageListButton()
		} else {
			self.navigationItem.title = "게시물"
		}
	}

	func setupMessageListButton() {

		messageListButton.setBackgroundImage(UIImage(systemName: "paperplane.fill"), for: .normal)
		messageListButton.layer.cornerRadius = 15
		messageListButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//		messageListButton.tintColor = .systemBlue


//		messageListButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
		messageListButton.addTarget(self, action: #selector(messageListButtonTapped), for: .touchUpInside)

		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: messageListButton)
	}

	@objc private func messageListButtonTapped() {

		navigationController?.pushViewController(MessageListViewController(), animated: true)
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
	let deleteButtonTapped = PublishSubject<Int>()
	let confirmDeleteTapped = PublishSubject<Int>()
	let likeButtonTapped = PublishSubject<Int>()
	let disLikeButtonTapped = PublishSubject<Int>()

	let input = PostViewModel.Input(deleteButtonTap: confirmDeleteTapped.asObservable(),
									likeButtonTap: likeButtonTapped.asObservable(),
									disLikeButtonTap: disLikeButtonTapped.asObservable())

	let output = viewModel.transform(input: input)


	output.data
		.drive(tableView.rx.items(cellIdentifier: PostTableViewCell.id, cellType: PostTableViewCell.self)) {
			row, element, cell in
			cell.selectionStyle = .none
			print("\(row) 여기가 언제 실행되는가")
			print(element.buyers)

			let myId = UserDefaultsManager.userId
//			guard let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) else {
//				return
//			}

			if myId == element.creator.user_id {
				cell.deleteButton.isHidden = false
				cell.buyButton.isHidden = true
				if element.buyers.count >= 1 {
					cell.buyButton.isHidden = false
					cell.buyButton.setTitle("판매완료", for: .normal)
					cell.buyButton.backgroundColor = .darkGray
					cell.buyButton.isEnabled = false
					cell.deleteButton.snp.remakeConstraints { make in
						make.bottom.equalTo(cell.postImageView.snp.top).offset(-10)
						make.trailing.equalTo(cell.buyButton.snp.leading).offset(-10)
					
					}
				}
			} else {
				cell.deleteButton.isHidden = true
				cell.buyButton.isHidden = false
				if element.buyers.count >= 1 {
					cell.buyButton.setTitle("판매완료", for: .normal)
					cell.buyButton.backgroundColor = .darkGray
					cell.buyButton.isEnabled = false
				}
			}

			cell.like = element.likes.contains(myId)
			cell.dislike = element.likes2.contains(myId)

			//삭제 버튼
			cell.deleteButton.rx.tap
				.subscribe(with: self, onNext: { owner, _ in

					owner.showDeletionAlert(for: row, deleteSubject: confirmDeleteTapped) {

						if self.viewModel.totalOrDetail {
							confirmDeleteTapped.onNext(row)
							self.reloadData()
						} else {
							confirmDeleteTapped.onNext(row)
							self.navigationController?.popViewController(animated: true)
						}
					}
				})
				.disposed(by: cell.disposeBag)


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
					vc.commentVCDelegate = owner
					vc.viewModel.postID = element.post_id

					let nav = UINavigationController(rootViewController: vc)
					owner.present(nav, animated: true)
				}
				.disposed(by: cell.disposeBag)

			cell.buyButton.rx.tap
				.subscribe(with: self) { owner, _ in

					let vc = PaymentViewController()
					vc.element = element
					owner.navigationController?.pushViewController(vc, animated: true)

				}
				.disposed(by: cell.disposeBag)


			DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
				self.refreshControl.endRefreshing()

				self.loadingLottieView.isHidden = true
				self.loadingLottieView.stop()
			}

		}

		.disposed(by: disposeBag)

	if viewModel.totalOrDetail {
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
			owner.loadingLottieView.isHidden = true
			owner.loadingLottieView.stop()
		}
		.disposed(by: disposeBag)
	}

	func playAppropriateAnimation(for type: String, likeCondition: Bool, dislikeCondition: Bool) {

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

extension PostViewController: CommentViewControllerDelegate {
	func pushOthersProfile(myOrOther: Bool, id: String) {
		let vc = ProfileViewController()

		if myOrOther {
			self.navigationController?.pushViewController(vc, animated: true)
		} else {
			vc.viewModel.myOrOther = false
			vc.viewModel.othersId = id
			vc.tabmanVC.myOrOthers = false
			vc.tabmanVC.myPostsVC.viewModel.myId = id
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
}

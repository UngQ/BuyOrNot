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



class PostViewController: BaseViewController {

	var TotalOrDetail = true

	let viewModel = PostViewModel()

	private var currentCategory = "전체"
	let tableView = UITableView()
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


		if TotalOrDetail {
			self.navigationItem.title = "최근 게시물"

			let menuButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: nil)
		 self.navigationItem.leftBarButtonItem = menuButton

		 // Define the menu actions
		 let menuActions = createMenuActions()

		 // Attach the menu to the bar button item
		 menuButton.menu = UIMenu(title: "", children: menuActions)
		 menuButton.primaryAction = nil  // Ensure tapping the button opens the menu
		} else {
			self.navigationItem.title = "게시물"
		}

	}

	func createMenuActions() -> [UIMenuElement] {
		let categories = [Category.top,
						  Category.bottom,
						  Category.shoes,
						  Category.acc]

		return categories.map { category in
			UIAction(title: category.title, image: nil, handler: { action in

				self.handleCategorySelection(category)
			})
		}
	}

	func handleCategorySelection(_ category: Category) {
		print("Selected category: \(category)")
		let vc = ContentPostViewController()
		vc.viewModel.title = category.title
		vc.viewModel.hashTag = category.rawValue
		
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

			let likes = element.likes
			let disLikes = element.likes2
			guard let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) else {
				return
			}
			let myLike = likes.contains(myId)
			let myDisLike = disLikes.contains(myId)




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
				cell.likeDislikeProgressView.setProgress(0, animated: true)

			} else {
				
				cell.likeDislikeProgressView.trackTintColor = .systemRed
				cell.likeDislikeProgressView.setProgress(likeRatio, animated: true)
			}




			//셀 포스트 이미지
			let postImage = "\(APIKey.baseURL.rawValue)/v1/\(element.files[0])"
			cell.postImageView.loadImage(from: postImage)

			cell.titleNPriceLabel.text = "\(element.title) / \(element.content1)"
			cell.likeLabel.text = "사세요 \(element.likes.count)개"
			cell.dislikeLabel.text = "마세요 \(element.likes2.count)개"
			cell.timeLabel.text = element.createdAt.formattedDate()

			if myLike {
				cell.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
			} else {
				cell.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
			}

			if myDisLike {
				cell.dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
			} else {
				cell.dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
			}

			cell.leftTap = {
				likeButtonTapped.onNext(row)
			}
			cell.rightTap = {
				disLikeButtonTapped.onNext(row)
			}

			cell.likeButton.rx.tap
				.map { row}
//				.do { _ in cell.animateButton(cell.likeButton) }
				.bind(to: likeButtonTapped)
				.disposed(by: cell.disposeBag)



			cell.dislikeButton.rx.tap
				.map { row }
//				.do { _ in cell.animateButton(cell.dislikeButton) }
				.bind(to: disLikeButtonTapped)
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


		}

		.disposed(by: disposeBag)

	tableView.rx.reachedBottom
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
		view.addSubview(tableView)
//		tableView.estimatedRowHeight = 200
//		tableView.rowHeight = UITableView.automaticDimension


		tableView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide)
			make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
		}

		tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.id)
		tableView.refreshControl = refreshControl
		refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)


	}




}

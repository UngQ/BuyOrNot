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



class TotalPostViewController: BaseViewController {

	let viewModel = TotalPostViewModel()

	private var currentCategory = "전체"
	let tableView = UITableView()
	

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		print("GGG")
		viewModel.viewWillAppearTrigger.accept(())
		tableView.reloadData()
	}

    override func viewDidLoad() {
        super.viewDidLoad()


	
	 }

	

override func bind() {
	let likeButtonTapped = PublishSubject<Int>()
	let disLikeButtonTapped = PublishSubject<Int>()

	let input = TotalPostViewModel.Input(
		likeButtonTap: likeButtonTapped.asObservable(),
										 disLikeButtonTap: disLikeButtonTapped.asObservable())

	let output = viewModel.transform(input: input)


	output.data
		.drive(tableView.rx.items(cellIdentifier: PostTableViewCell.id, cellType: PostTableViewCell.self)) {
			row, element, cell in
			let likes = element.likes
			let disLikes = element.likes2
			guard let myId = UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) else {
				return
			}
			var myLike = likes.contains(myId)
			var myDisLike = disLikes.contains(myId)

			cell.selectionStyle = .none


			//셀 프로필 이미지
			let profileImage = "\(APIKey.baseURL.rawValue)/v1/\(element.creator.profileImage)"
			cell.profileImageView.kf.setImage(with: URL(string: profileImage), options: [.requestModifier(NetworkManager.imageDownloadRequest)], completionHandler: { response in
				switch response {
				case .success(let data):
					DispatchQueue.main.async {
						cell.profileImageView.image = data.image

						cell.layoutSubviews() // Refresh cell layout if needed
					}
				case .failure(let error):
					print("Error setting image: \(error)")
					DispatchQueue.main.async {
						cell.imageView?.image = UIImage(systemName: "exclamationmark.triangle") // Fallback image in case of error
					}
				}
			}
			)

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
			cell.postImageView.kf.setImage(with: URL(string: postImage), options: [.requestModifier(NetworkManager.imageDownloadRequest)], completionHandler: { response in
				switch response {
				case .success(let data):
					DispatchQueue.main.async {
						cell.postImageView.image = data.image

						cell.layoutSubviews() // Refresh cell layout if needed
					}
				case .failure(let error):
					print("Error setting image: \(error)")
					DispatchQueue.main.async {
						cell.imageView?.image = UIImage(systemName: "exclamationmark.triangle") // Fallback image in case of error
					}
				}
			}
			)




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
				.map { row }
				.bind(to: likeButtonTapped)
				.disposed(by: cell.disposeBag)



			cell.dislikeButton.rx.tap
				.map { row }
				.bind(to: disLikeButtonTapped)
				.disposed(by: cell.disposeBag)



//			cell.likeButton.rx.tap
//				.bind(with: self) { owner, _ in
//					myLike.toggle()
//					if myLike {
//						cell.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
//					} else {
//						cell.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
//					}
//				}
//				.disposed(by: cell.disposeBag)

		
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


	}




}

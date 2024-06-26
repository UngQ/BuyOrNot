//
//  ProfileViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/21/24.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftUI


final class ProfileViewController: BaseViewController {

	let viewModel = ProfileViewModel()

	private var containerView = UIView()
	let tabmanVC = TabmanInProfileViewController()

	let logoutOrFollowButton = UIButton()
	let profileSettingButton = UIButton()
	let messageButton = UIButton()

	let profileImageView = UIImageView()

	let postsLabel = UILabel()
	let followersLabel = UILabel()
	let followingLabel = UILabel()

	let postsButton = UIButton()
	let followersButton = UIButton()
	let followingButton = UIButton()


	lazy var postsStackView = UIStackView(arrangedSubviews: [postsLabel, postsButton])
	lazy var followersStackView = UIStackView(arrangedSubviews: [followersLabel, followersButton])
	lazy var followingStackView = UIStackView(arrangedSubviews: [followingLabel, followingButton])
	lazy var horizontalStackView = UIStackView(arrangedSubviews: [postsStackView, followersStackView, followingStackView])

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		viewModel.viewWillAppearTrigger.accept(())

		tabmanVC.myPostsVC.viewModel.isLoading = false
		tabmanVC.myPostsVC.viewModel.nextCursor = nil
		tabmanVC.myPostsVC.viewModel.viewWillAppearTrigger.accept(())

		tabmanVC.likePostsVC.viewModel.isLoading = false
		tabmanVC.likePostsVC.viewModel.nextCursor = nil
		tabmanVC.likePostsVC.viewModel.viewWillAppearTrigger.accept(())

		tabmanVC.dislikePostsVC.viewModel.isLoading = false
		tabmanVC.dislikePostsVC.viewModel.nextCursor = nil
		tabmanVC.dislikePostsVC.viewModel.viewWillAppearTrigger.accept(())

		print("Hey!")

	}

	 override func viewDidLoad() {
		 super.viewDidLoad()
		 self.view.backgroundColor = .white
		 setupProfileViews()
		 configureButtons()

		 tabmanVC.myPostsVC.contentPostVCDelegate = self
		 tabmanVC.likePostsVC.contentPostVCDelegate = self
		 tabmanVC.dislikePostsVC.contentPostVCDelegate = self
		 tabmanVC.purchaseListVC.contentPostVCDelegate = self


	 }

	private func configureButtons() {

		postsLabel.text = "게시물"
		postsLabel.textAlignment = .center
		postsLabel.font = .systemFont(ofSize: 16)
		postsLabel.textColor = .darkGray
		followersLabel.text = "팔로워"
		followersLabel.textAlignment = .center
		followersLabel.font = .systemFont(ofSize: 16)
		followersLabel.textColor = .darkGray
		followingLabel.text = "팔로잉"
		followingLabel.textAlignment = .center
		followingLabel.font = .systemFont(ofSize: 16)
		followingLabel.textColor = .darkGray
		postsButton.titleLabel?.textAlignment = .center
		postsButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
		followersButton.titleLabel?.textAlignment = .center
		followersButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
		followingButton.titleLabel?.textAlignment = .center
		followingButton.titleLabel?.font = .boldSystemFont(ofSize: 16)


		postsButton.setTitleColor(.textPoint, for: .normal)
		postsButton.addTarget(self, action: #selector(postsButtonTapped), for: .touchUpInside)



		 followersButton.setTitleColor(.textPoint, for: .normal)
		 followersButton.addTarget(self, action: #selector(followersButtonTapped), for: .touchUpInside)


		 followingButton.setTitleColor(.textPoint, for: .normal)
		 followingButton.addTarget(self, action: #selector(followingButtonTapped), for: .touchUpInside)
	 }

	@objc private func postsButtonTapped() {
		UIView.animate(withDuration: 0.3) {
			self.horizontalStackView.isHidden = true
			self.containerView.snp.remakeConstraints { make in
				make.edges.equalTo(self.view.safeAreaLayoutGuide)
			}
			
			self.view.layoutIfNeeded()
		}

	}

	@objc private func followersButtonTapped() {
		let followersVC = FollowViewController()
		followersVC.followerOrFollowing = true
		followersVC.viewModel = viewModel
		navigationController?.pushViewController(followersVC, animated: true)
	}

	@objc private func followingButtonTapped() {
		let followingVC = FollowViewController()
		followingVC.followerOrFollowing = false
		followingVC.viewModel = viewModel
		navigationController?.pushViewController(followingVC, animated: true)
	}


	override func bind() {
		let input = ProfileViewModel.Input(navigationRightButtonTapped: logoutOrFollowButton.rx.tap,
										   messageButtonTapped: messageButton.rx.tap,
										   deleteButtonTapped: nil
										   ,unfollowButtonTapped: nil,
										   followButtonTapped: nil)

		let output = viewModel.transform(input: input)



		output.data
			.drive(with: self) { owner, profileData in

				if owner.viewModel.myOrOther || profileData.user_id == owner.viewModel.myId {
					owner.logoutOrFollowButton.setImage(UIImage(systemName: "door.left.hand.open"), for: .normal)
					owner.logoutOrFollowButton.layer.backgroundColor = UIColor(white: 0, alpha: 0.2).cgColor
					owner.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: owner.logoutOrFollowButton),
																UIBarButtonItem(customView: owner.profileSettingButton) ]

				} else {

					let followerIds = profileData.followers.map { $0.user_id }
					let isFollower = followerIds.contains(owner.viewModel.myId)
					if isFollower {
						owner.logoutOrFollowButton.setImage(UIImage(systemName: "person.crop.circle.fill.badge.minus"), for: .normal)
						owner.logoutOrFollowButton.backgroundColor = .systemRed
					} else {
						owner.logoutOrFollowButton.setImage(UIImage(systemName: "person.crop.circle.fill.badge.plus"), for: .normal)
						owner.logoutOrFollowButton.backgroundColor = .systemBlue
					}
					owner.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: owner.logoutOrFollowButton),
																UIBarButtonItem(customView: owner.messageButton)]
				}



				let profileImage = "\(APIKey.baseURL.rawValue)/v1/\(profileData.profileImage ?? "")"
				owner.profileImageView.loadImage(from: profileImage)

				owner.postsButton.setTitle("\(profileData.posts.count)", for: .normal)
				owner.followersButton.setTitle("\(profileData.followers.count)", for: .normal)
				owner.followingButton.setTitle("\(profileData.following.count)", for: .normal)

				owner.navigationItem.title = "\(profileData.nick)"

			}
			.disposed(by: disposeBag)

		output.navigationRightButtonTapped.drive(with: self) { owner, _ in
			if owner.viewModel.myOrOther || owner.viewModel.profileData.value.user_id == owner.viewModel.myId {
				let alertController = UIAlertController(title: nil, message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
				let logoutAction = UIAlertAction(title: "로그아웃", style: .destructive) { _ in

					let vc = SignInViewController()
					vc.viewModel.handleAutoLogin("", password: "", enable: false)
					UIViewController.changeRootView(to: vc, isNav: true)

				}
				let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
				alertController.addAction(logoutAction)
				alertController.addAction(cancelAction)
				owner.present(alertController, animated: true)
			} else {
				print("팔로우/언팔 뷰모델에서 작업")
			}
		}
		.disposed(by: disposeBag)

		profileSettingButton.rx.tap
			.asDriver()
			.drive(with: self) { owner, _ in
				let vc = EditProfileViewController()
				vc.viewModel.profileData.accept(owner.viewModel.profileData.value)
				owner.navigationController?.pushViewController(vc, animated: true)
			}
			.disposed(by: disposeBag)

		output.messageButtonTapped
			.drive(with: self) { owner, roomId in
				owner.tabBarController?.tabBar.isHidden = true
				print(roomId)
				let nick = owner.viewModel.profileData.value.nick

				SocketIOManager.shared.fetchSocket(roomId: roomId)

				
				let chatRoomView = ChatRoomView(viewModel: ChatRoomViewModel(chatId: roomId, nick: nick))

				let hostingController = UIHostingController(rootView: chatRoomView)
				
				owner.navigationController?.pushViewController(hostingController, animated: true)
			}
			.disposed(by: disposeBag)


	}

	 private func setupProfileViews() {
		 logoutOrFollowButton.layer.cornerRadius = 15
		 logoutOrFollowButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
		 logoutOrFollowButton.tintColor = .white

		 profileSettingButton.setBackgroundImage(UIImage(systemName: "gearshape.fill"), for: .normal)
		 profileSettingButton.layer.cornerRadius = 15
		 profileSettingButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
		 profileSettingButton.tintColor = .systemBlue

		 messageButton.setBackgroundImage(UIImage(systemName: "plus.message.fill"), for: .normal)
		 messageButton.layer.cornerRadius = 15
		 messageButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//		 profileSettingButton.tintColor = .systemBlue


		 [postsStackView, followersStackView, followingStackView].forEach { stackView in
			 stackView.axis = .vertical
			 stackView.spacing = 0
			 stackView.distribution = .fillEqually
		 }

		 horizontalStackView.axis = .horizontal
		 horizontalStackView.distribution = .fillEqually
		 horizontalStackView.spacing = 20
		 horizontalStackView.alignment = .center

		 view.addSubview(profileImageView)
		 view.addSubview(horizontalStackView)
		 view.addSubview(containerView)
		 containerView.addSubview(tabmanVC.view)



		 profileImageView.snp.makeConstraints { make in
			 make.top.equalTo(view.safeAreaLayoutGuide).offset(4)
			 make.leading.equalTo(view.safeAreaLayoutGuide).offset(12)
			 make.width.height.equalTo(100)
		 }

		 horizontalStackView.snp.makeConstraints { make in
			 make.centerY.equalTo(profileImageView)
			 make.leading.equalTo(profileImageView.snp.trailing).offset(4)
			 make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-4)
		  }


		 containerView.snp.makeConstraints { make in
			 make.top.equalTo(profileImageView.snp.bottom).offset(10)
			 make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
		 }


		 tabmanVC.view.snp.makeConstraints { make in
			 make.edges.equalToSuperview()
		 }

		 profileImageView.layer.cornerRadius = 50
		 profileImageView.clipsToBounds = true


	 }


}


extension ProfileViewController: ContentPostViewControllerDelegate {
	func didScrollTableView(_ direction: ScrollDirection) {
		switch direction {
		case .down:

				UIView.animate(withDuration: 0.3) {
					self.horizontalStackView.isHidden = false
					self.containerView.snp.remakeConstraints { make in
						make.top.equalTo(self.profileImageView.snp.bottom).offset(10)
						make.horizontalEdges.equalToSuperview()
						make.bottom.equalTo(self.view.safeAreaLayoutGuide)
					}
					self.view.layoutIfNeeded()
				}

		case .up:
			UIView.animate(withDuration: 0.3) {
				self.horizontalStackView.isHidden = true
				self.containerView.snp.remakeConstraints { make in
					   make.edges.equalTo(self.view.safeAreaLayoutGuide)
				   }
				self.view.layoutIfNeeded()


			}
		}
	}
	
	func didSelectItem(index: Int) {
		self.navigationController?.isNavigationBarHidden = false
		let vc = PostViewController()
		vc.viewModel.totalOrDetail = false
		if self.tabmanVC.currentIndex == 0 {
			vc.viewModel.id = self.tabmanVC.myPostsVC.viewModel.postsData.value[index].post_id
		} else if self.tabmanVC.currentIndex == 1 {
			vc.viewModel.id = self.tabmanVC.likePostsVC.viewModel.postsData.value[index].post_id
		} else if self.tabmanVC.currentIndex == 2 {
			vc.viewModel.id = self.tabmanVC.dislikePostsVC.viewModel.postsData.value[index].post_id
		} else if self.tabmanVC.currentIndex == 3 {
			vc.viewModel.id = self.tabmanVC.purchaseListVC.viewModel.postsData.value.data[index].post_id
		}
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	
}

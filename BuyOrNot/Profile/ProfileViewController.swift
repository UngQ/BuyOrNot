//
//  ProfileViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/21/24.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileViewController: BaseViewController {

	let viewModel = ProfileViewModel()

	private var containerView = UIView()
	let tabmanVC = TabmanInProfileViewController()

	let navigationRightButton = UIButton()

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


		print("Hey!")

	}

	 override func viewDidLoad() {
		 super.viewDidLoad()
		 self.view.backgroundColor = .white
		 setupProfileViews()
		 configureButtons()
		 setupUserNavigationItem()
		 
		 tabmanVC.myPostsVC.contentPostVCDelegate = self
		 tabmanVC.likePostsVC.contentPostVCDelegate = self
		 tabmanVC.dislikePostsVC.contentPostVCDelegate = self

		 viewModel.viewWillAppearTrigger.accept(())
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


		postsButton.setTitleColor(.textPoint, for: .normal) // Customize color as needed
		postsButton.addTarget(self, action: #selector(followersButtonTapped), for: .touchUpInside)



		 followersButton.setTitleColor(.textPoint, for: .normal) // Customize color as needed
		 followersButton.addTarget(self, action: #selector(followersButtonTapped), for: .touchUpInside)


		 followingButton.setTitleColor(.textPoint, for: .normal) // Customize color as needed
		 followingButton.addTarget(self, action: #selector(followingButtonTapped), for: .touchUpInside)
	 }

	@objc private func followersButtonTapped() {
		// Navigate to followers list screen
		let followersVC = FollowViewController()
		followersVC.followerOrFollowing = true
		followersVC.viewModel = viewModel
		navigationController?.pushViewController(followersVC, animated: true)
	}

	@objc private func followingButtonTapped() {
		// Navigate to following list screen
		let followingVC = FollowViewController()
		followingVC.followerOrFollowing = false
		followingVC.viewModel = viewModel
		navigationController?.pushViewController(followingVC, animated: true)
	}

	private func setupUserNavigationItem() {

		}


	override func bind() {
		let input = ProfileViewModel.Input(navigationRightButtonTapped: navigationRightButton.rx.tap,
										   deleteButtonTapped: nil)

		let output = viewModel.transform(input: input)

		output.data
			.drive(with: self) { owner, profileData in

				if owner.viewModel.myOrOther || profileData.user_id == owner.viewModel.myId {
					owner.navigationRightButton.setImage(UIImage(systemName: "door.left.hand.open"), for: .normal)
					owner.navigationRightButton.layer.backgroundColor = UIColor(white: 0, alpha: 0.2).cgColor
				} else {

					let followerIds = profileData.followers.map { $0.user_id }
					let isFollower = followerIds.contains(owner.viewModel.myId)
					if isFollower {
						owner.navigationRightButton.setImage(UIImage(systemName: "person.crop.circle.fill.badge.minus"), for: .normal)
						owner.navigationRightButton.backgroundColor = .systemRed
					} else {
						owner.navigationRightButton.setImage(UIImage(systemName: "person.crop.circle.fill.badge.plus"), for: .normal)
						owner.navigationRightButton.backgroundColor = .systemBlue
					}
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


	}

	 private func setupProfileViews() {
		 navigationRightButton.layer.cornerRadius = 15
		 navigationRightButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
		 navigationRightButton.tintColor = .white
		 navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navigationRightButton)

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
					self.navigationController?.isNavigationBarHidden = false
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
				self.navigationController?.isNavigationBarHidden = true
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
		vc.TotalOrDetail = false
		if self.tabmanVC.currentIndex == 0 {
			vc.viewModel.id = self.tabmanVC.myPostsVC.viewModel.postsData.value[index].post_id
		} else if self.tabmanVC.currentIndex == 1 {
			vc.viewModel.id = self.tabmanVC.likePostsVC.viewModel.postsData.value[index].post_id
		} else if self.tabmanVC.currentIndex == 2 {
			vc.viewModel.id = self.tabmanVC.dislikePostsVC.viewModel.postsData.value[index].post_id
		}
		vc.viewModel.totalOrDetail = false
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	
}

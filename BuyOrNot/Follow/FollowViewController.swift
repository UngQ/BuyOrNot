//
//  FollowViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/28/24.
//

import UIKit
import RxSwift

final class FollowViewController: BaseViewController {

	var viewModel: ProfileViewModel?

	var followerOrFollowing = true


	let listTableView = UITableView()
	let emptyLabel = {
		let view = UILabel()
		view.text = "아직 팔로워/팔로잉이 없습니다."
		view.font = .boldSystemFont(ofSize: 16)
		view.textAlignment = .center
		return view
	}()

    override func viewDidLoad() {
        super.viewDidLoad()

		setNavigationTitleImage()
		print(viewModel?.profileData.value)

    }

	override func bind() {
		let deleteButtonTapped = PublishSubject<Int>()
		let followButtonTapped = PublishSubject<Int>()
		let unfollowButtonTapped = PublishSubject<Int>()

		let input = ProfileViewModel.Input(navigationRightButtonTapped: nil,
										   messageButtonTapped: nil,
										   deleteButtonTapped: deleteButtonTapped.asObservable(),
										   unfollowButtonTapped: unfollowButtonTapped.asObservable(),
										   followButtonTapped: followButtonTapped.asObservable())

		guard let viewModel = viewModel else { return }

		let output = viewModel.transform(input: input)



		//팔로워 뷰
		if self.followerOrFollowing {

			output.data.map({ $0.followers })
				.drive(with: self) { owner, follow in
					if follow == [] {
						owner.emptyLabel.isHidden = false
					} else {
						owner.emptyLabel.isHidden = true
					}
				}
				.disposed(by: disposeBag)

			output.data.map { $0.followers }
				.drive(listTableView.rx.items(cellIdentifier: FollowTableViewCell.id, cellType: FollowTableViewCell.self)) { row, element, cell  in
					cell.selectionStyle = .none

					guard let viewModel = self.viewModel else { return }


					cell.profileImageView.rx.tapGesture()
						.when(.recognized)
						.bind(with: self) { owner, gesture in
							let vc = ProfileViewController()

							if element.user_id == viewModel.myId {

								owner.navigationController?.pushViewController(vc, animated: true)
							} else {
								vc.viewModel.myOrOther = false
								vc.viewModel.othersId = element.user_id
								vc.tabmanVC.myOrOthers = false
								vc.tabmanVC.myPostsVC.viewModel.myId = element.user_id
								owner.navigationController?.pushViewController(vc, animated: true)
							}
						}
						.disposed(by: cell.disposeBag)

					cell.nicknameLabel.rx.tapGesture()
						.when(.recognized)
						.bind(with: self) { owner, gesture in
							let vc = ProfileViewController()

							if element.user_id == viewModel.myId {
								owner.navigationController?.pushViewController(vc, animated: true)
							} else {
								vc.viewModel.myOrOther = false
								vc.viewModel.othersId = element.user_id
								vc.tabmanVC.myOrOthers = false
								vc.tabmanVC.myPostsVC.viewModel.myId = element.user_id
								owner.navigationController?.pushViewController(vc, animated: true)
							}
						}
						.disposed(by: cell.disposeBag)

					cell.nicknameLabel.text = element.nick
					if let endPoint = element.profileImage {
						let profileImage = "\(APIKey.baseURL.rawValue)/v1/\(endPoint)"
						cell.profileImageView.loadImage(from: profileImage)
					}

					//내프로필 내 팔로워
					if viewModel.myOrOther {
						viewModel.followerOrFollowing = true
						print("놀아와와와")
						cell.followButton.backgroundColor = .red


//						cell.followButton.rx
//							.tap
//							.map { row }
//							.bind(to: deleteButtonTapped)
//							.disposed(by: cell.disposeBag)
//
//						cell.followButton.rx.tap.subscribe(with: self) { owner, _ in
//							print("눌리냐")
//						}
//						.disposed(by: cell.disposeBag)
						//						cell.followButton.rx.tap

						//							.map { row }
						//							.bind(to: deleteButtonTapped)
						//							.disposed(by: cell.disposeBag)
						let isFollowing = viewModel.myFollowingData.contains { $0.user_id == element.user_id }

						if isFollowing {
							cell.followButton.setTitle("언팔하기", for: .normal)
							cell.followButton.backgroundColor = .lightGray
							cell.followButton.rx
								.tap
								.map { row }
								.bind(to: unfollowButtonTapped)
								.disposed(by: cell.disposeBag)
						} else {
							cell.followButton.setTitle("팔로우하기", for: .	normal)
							cell.followButton.backgroundColor = .systemBlue
							cell.followButton.rx
								.tap
								.map { row }
								.bind(to: followButtonTapped)
								.disposed(by: cell.disposeBag)
						}


					} else {
					// 다른사람 프로필 팔로워
						viewModel.followerOrFollowing = true
						//내 계정은 버튼 삭제
						if element.user_id == viewModel.myId {
							cell.followButton.isHidden = true
						} else {
							let isFollowing = viewModel.myFollowingData.contains { $0.user_id == element.user_id }

							if isFollowing {
								cell.followButton.setTitle("언팔하기", for: .normal)
								cell.followButton.backgroundColor = .lightGray
								cell.followButton.rx
									.tap
									.map { row }
									.bind(to: unfollowButtonTapped)
									.disposed(by: cell.disposeBag)
							} else {
								cell.followButton.setTitle("팔로우하기", for: .	normal)
								cell.followButton.backgroundColor = .systemBlue
								cell.followButton.rx
									.tap
									.map { row }
									.bind(to: followButtonTapped)
									.disposed(by: cell.disposeBag)
							}

						}




					}
				}
				.disposed(by: disposeBag)
		}	else {
			//팔로잉 뷰

			output.data.map({ $0.following })
				.drive(with: self) { owner, follow in
					if follow == [] {
						owner.emptyLabel.isHidden = false

					} else {
						owner.emptyLabel.isHidden = true
					}
				}
				.disposed(by: disposeBag)


			output.data.map { $0.following }
				.drive(listTableView.rx.items(cellIdentifier: FollowTableViewCell.id, cellType: FollowTableViewCell.self)) { row, element, cell  in
					cell.selectionStyle = .none

					guard let viewModel = self.viewModel else { return }


					cell.profileImageView.rx.tapGesture()
						.when(.recognized)
						.bind(with: self) { owner, gesture in
							let vc = ProfileViewController()

							if element.user_id == viewModel.myId {

								owner.navigationController?.pushViewController(vc, animated: true)
							} else {
								vc.viewModel.myOrOther = false
								vc.viewModel.othersId = element.user_id
								vc.tabmanVC.myOrOthers = false
								vc.tabmanVC.myPostsVC.viewModel.myId = element.user_id
								owner.navigationController?.pushViewController(vc, animated: true)
							}
						}
						.disposed(by: cell.disposeBag)

					cell.nicknameLabel.rx.tapGesture()
						.when(.recognized)
						.bind(with: self) { owner, gesture in
							let vc = ProfileViewController()

							if element.user_id == viewModel.myId {
								owner.navigationController?.pushViewController(vc, animated: true)
							} else {
								vc.viewModel.myOrOther = false
								vc.viewModel.othersId = element.user_id
								vc.tabmanVC.myOrOthers = false
								vc.tabmanVC.myPostsVC.viewModel.myId = element.user_id
								owner.navigationController?.pushViewController(vc, animated: true)
							}
						}
						.disposed(by: cell.disposeBag)

					cell.nicknameLabel.text = element.nick
					if let endPoint = element.profileImage {
						let profileImage = "\(APIKey.baseURL.rawValue)/v1/\(endPoint)"
						cell.profileImageView.loadImage(from: profileImage)
					}

					if viewModel.myOrOther {
						viewModel.followerOrFollowing = true

						cell.followButton.setTitle("삭제", for: .normal)
						cell.followButton.backgroundColor = .lightGray


						cell.followButton.rx
							.tap
							.map { row }
							.bind(to: deleteButtonTapped)
							.disposed(by: cell.disposeBag)

					} else {
						// 다른사람 프로필 팔로잉
						viewModel.followerOrFollowing = false
						//내 프로필은 버튼 삭제
						if element.user_id == viewModel.myId {
							cell.followButton.isHidden = true
						} else {
							let isFollowing = viewModel.myFollowingData.contains { $0.user_id == element.user_id }

							if isFollowing {
								cell.followButton.setTitle("언팔하기", for: .normal)
								cell.followButton.backgroundColor = .lightGray
								cell.followButton.rx
									.tap
									.map { row }
									.bind(to: unfollowButtonTapped)
									.disposed(by: cell.disposeBag)
							} else {
								cell.followButton.setTitle("팔로우하기", for: .	normal)
								cell.followButton.backgroundColor = .systemBlue
								cell.followButton.rx
									.tap
									.map { row }
									.bind(to: followButtonTapped)
									.disposed(by: cell.disposeBag)
							}

						}
					}


				}
				.disposed(by: disposeBag)
			}





//		output.data.map {
//			if self.followerOrFollowing { $0.followers }
//			else { $0.following }
//		}
//			.drive(listTableView.rx.items(cellIdentifier: FollowTableViewCell.id, cellType: FollowTableViewCell.self)) {
//				row, element, cell in
//
//
//				cell.nicknameLabel.text = element.nick
//
//				if let endPoint = element.profileImage {
//					let profileImage = "\(APIKey.baseURL.rawValue)/v1/\(endPoint)"
//					cell.profileImageView.loadImage(from: profileImage)
//				}
//
//
//			}
//			.disposed(by: disposeBag)

	
	}

	override func configureLayout() {
		view.addSubview(listTableView)

		listTableView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}

		listTableView.register(FollowTableViewCell.self, forCellReuseIdentifier: FollowTableViewCell.id)
		listTableView.rowHeight = 80

		view.addSubview(emptyLabel)

		emptyLabel.snp.makeConstraints { make in
			make.centerY.centerX.equalToSuperview()
		}
	}



}

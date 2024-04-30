//
//  FollowViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/28/24.
//

import UIKit
import RxSwift

class FollowViewController: BaseViewController {

	var viewModel: ProfileViewModel?

	var followerOrFollowing = true


	let listTableView = UITableView()
	

    override func viewDidLoad() {
        super.viewDidLoad()

		setNavigationTitleImage()
		print(viewModel?.profileData.value)

    }

	override func bind() {
		let deleteButtonTapped = PublishSubject<Int>()

		let input = ProfileViewModel.Input(navigationRightButtonTapped: nil,
										   deleteButtonTapped: deleteButtonTapped.asObservable())

		guard let viewModel = viewModel else { return }

		let output = viewModel.transform(input: input)

		//팔로워 뷰
		if self.followerOrFollowing {
			output.data.map { $0.followers }
				.drive(listTableView.rx.items(cellIdentifier: FollowTableViewCell.id, cellType: FollowTableViewCell.self)) { row, element, cell  in

					guard let viewModel = self.viewModel else { return }

					cell.nicknameLabel.text = element.nick
					if let endPoint = element.profileImage {
						let profileImage = "\(APIKey.baseURL.rawValue)/v1/\(endPoint)"
						cell.profileImageView.loadImage(from: profileImage)
					}

					if viewModel.myOrOther {

						cell.followButton.backgroundColor = .brown


						cell.followButton.rx
							.tap
							.map { row }
							.bind(to: deleteButtonTapped)
							.disposed(by: cell.disposeBag)

						cell.followButton.rx.tap.subscribe(with: self) { owner, _ in
							print("눌리냐")
						}
						.disposed(by: cell.disposeBag)
						//						cell.followButton.rx.tap

						//							.map { row }
						//							.bind(to: deleteButtonTapped)
						//							.disposed(by: cell.disposeBag)

					}
				}
				.disposed(by: disposeBag)
		}	else {
			//팔로잉 뷰
			output.data.map { $0.following }
				.drive(listTableView.rx.items(cellIdentifier: FollowTableViewCell.id, cellType: FollowTableViewCell.self)) { row, element, cell  in

					guard let viewModel = self.viewModel else { return }

					cell.nicknameLabel.text = element.nick
					if let endPoint = element.profileImage {
						let profileImage = "\(APIKey.baseURL.rawValue)/v1/\(endPoint)"
						cell.profileImageView.loadImage(from: profileImage)
					}

					if viewModel.myOrOther {


						cell.followButton.backgroundColor = .brown


						cell.followButton.rx
							.tap
							.map { row }
							.bind(to: deleteButtonTapped)
							.disposed(by: cell.disposeBag)

						cell.followButton.rx.tap.subscribe(with: self) { owner, _ in
							print("눌리냐")
						}
						.disposed(by: cell.disposeBag)
					} else {
						cell.followButton.isHidden = true
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

	}



}

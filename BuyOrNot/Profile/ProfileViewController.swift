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

	// Profile UI Components
	let profileImageView = UIImageView()
	let nameLabel = UILabel()
	let followersLabel = UILabel()
	let followingLabel = UILabel()
	private lazy var imageCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout.createThreeColumnFlowLayout(in: self.view)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.id)
		return collectionView
	}()

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		viewModel.viewWillAppearTrigger.accept(())
	}

	 override func viewDidLoad() {
		 super.viewDidLoad()
		 self.view.backgroundColor = .white
		 setupProfileViews()
//		 setupCollectionView()
		 
	 }

	override func bind() {
		let input = ProfileViewModel.Input()

		let output = viewModel.transform(input: input)
		
		output.data
			.drive(
				imageCollectionView.rx.items(cellIdentifier: ImageCollectionViewCell.id, cellType: ImageCollectionViewCell.self)) {
					row, element, cell in

					let postImage = "\(APIKey.baseURL.rawValue)/v1/\(element.files[0])"
					cell.imageView.loadImage(from: postImage)


				}
				.disposed(by: disposeBag)
	}

	 private func setupProfileViews() {
		 view.addSubview(profileImageView)
		 view.addSubview(nameLabel)
		 view.addSubview(followersLabel)
		 view.addSubview(followingLabel)
		 view.addSubview(imageCollectionView)

		 profileImageView.snp.makeConstraints { make in
			 make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
			 make.centerX.equalTo(view)
			 make.width.height.equalTo(100)
		 }
		 profileImageView.layer.cornerRadius = 50
		 profileImageView.clipsToBounds = true
		 profileImageView.backgroundColor = .gray  // Placeholder color

		 nameLabel.text = "User Name"
		 nameLabel.snp.makeConstraints { make in
			 make.top.equalTo(profileImageView.snp.bottom).offset(10)
			 make.centerX.equalTo(view)
		 }

		 followersLabel.text = "Followers: 120"
		 followersLabel.snp.makeConstraints { make in
			 make.top.equalTo(nameLabel.snp.bottom).offset(10)
			 make.centerX.equalTo(view).offset(-50)
		 }

		 followingLabel.text = "Following: 150"
		 followingLabel.snp.makeConstraints { make in
			 make.top.equalTo(nameLabel.snp.bottom).offset(10)
			 make.centerX.equalTo(view).offset(50)
		 }

		 imageCollectionView.snp.makeConstraints { make in
			 make.top.equalTo(followersLabel.snp.bottom).offset(10)
			 make.horizontalEdges.equalToSuperview()
			 make.bottom.equalTo(view.safeAreaLayoutGuide)

		 }
		 imageCollectionView.backgroundColor = .brown
	 }


}

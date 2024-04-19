//
//  PostTableViewCell.swift
//  BuyOrNot
//
//  Created by ungQ on 4/19/24.
//

import UIKit
import SnapKit
import RxSwift

class PostTableViewCell: UITableViewCell {

	var disposeBag = DisposeBag()

	let profileImageView = UIImageView()
	let usernameLabel = UILabel()
	let postImageView = UIImageView()
	let likeButton = UIButton(type: .system)
	let dislikeButton = UIButton(type: .system)

	let bookmarkButton = UIButton(type: .system)
	let likesLabel = UILabel()
	let captionLabel = UILabel()
	let timeLabel = UILabel()

	let likeDislikeProgressView = UIProgressView(progressViewStyle: .default)

	override func prepareForReuse() {
		disposeBag = DisposeBag()
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(profileImageView)
		contentView.addSubview(usernameLabel)
		contentView.addSubview(postImageView)
		contentView.addSubview(likeButton)
		contentView.addSubview(dislikeButton)

		contentView.addSubview(bookmarkButton)
		contentView.addSubview(likesLabel)
		contentView.addSubview(captionLabel)
		contentView.addSubview(timeLabel)
		contentView.addSubview(likeDislikeProgressView)

		setupViews()
		setupConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupViews() {
		profileImageView.contentMode = .scaleAspectFill
		profileImageView.layer.cornerRadius = 15
		profileImageView.clipsToBounds = true

		usernameLabel.font = .systemFont(ofSize: 14, weight: .bold)

		postImageView.contentMode = .scaleAspectFill
		postImageView.clipsToBounds = true

		likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
		dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)

		bookmarkButton.setImage(UIImage(systemName: "message"), for: .normal)

		likesLabel.font = .systemFont(ofSize: 14, weight: .bold)
		captionLabel.font = .systemFont(ofSize: 14)
		captionLabel.numberOfLines = 0

		timeLabel.font = .systemFont(ofSize: 12)
		timeLabel.textColor = .gray


		postImageView.isUserInteractionEnabled = true
		let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTap))
		imageTapGesture.numberOfTapsRequired = 2
		postImageView.addGestureRecognizer(imageTapGesture)


	}

	@objc private func imageTap(gesture: UITapGestureRecognizer) {
		print(#function)
		let touchPoint = gesture.location(in: gesture.view)
		let width = gesture.view?.bounds.width ?? 0
		if touchPoint.x < width / 2 {
			print("Left half tapped")

		} else if touchPoint.x > width / 2 {
			print("Right half tapped")

		}
	}


	private func setupConstraints() {
		profileImageView.snp.makeConstraints { make in
			make.top.leading.equalToSuperview().offset(10)
			make.width.height.equalTo(30)
		}

		usernameLabel.snp.makeConstraints { make in
			make.centerY.equalTo(profileImageView)
			make.leading.equalTo(profileImageView.snp.trailing).offset(10)
		}

		postImageView.snp.makeConstraints { make in
			make.top.equalTo(profileImageView.snp.bottom).offset(10)
			make.horizontalEdges.equalToSuperview()
			make.height.equalTo(postImageView.snp.width)
		}

		likeDislikeProgressView.snp.makeConstraints { make in
			make.top.equalTo(postImageView.snp.bottom).offset(10)
			make.left.right.equalToSuperview().inset(10)
			make.height.equalTo(20)
//			make.bottom.equalToSuperview().offset(-10).priority(750)
		}

		likeButton.snp.makeConstraints { make in

			make.top.equalTo(likeDislikeProgressView.snp.bottom).offset(10)
			make.centerX.equalToSuperview().offset(-20)
			make.size.equalTo(25)
		}

		dislikeButton.snp.makeConstraints { make in
			make.top.equalTo(likeDislikeProgressView.snp.bottom).offset(10)
			make.centerX.equalToSuperview().offset(20)
			make.size.equalTo(25)
		}


		bookmarkButton.snp.makeConstraints { make in
			make.top.equalTo(likeDislikeProgressView.snp.bottom).offset(10)
			make.right.equalToSuperview().offset(-10)
			make.size.equalTo(25)
		}

		likesLabel.snp.makeConstraints { make in
			make.top.equalTo(likeButton.snp.bottom).offset(10)
			make.left.equalToSuperview().offset(10)
		}

		likesLabel.text = "likes"
		captionLabel.snp.makeConstraints { make in
			make.top.equalTo(likesLabel.snp.bottom).offset(4)
			make.left.right.equalToSuperview().inset(10)
		}
		captionLabel.text = "caption"

		timeLabel.snp.makeConstraints { make in
			make.top.equalTo(captionLabel.snp.bottom).offset(4)
			make.left.equalToSuperview().offset(10)
			make.bottom.equalToSuperview().offset(-10).priority(750)
		}
		timeLabel.text = "time"


	}
}

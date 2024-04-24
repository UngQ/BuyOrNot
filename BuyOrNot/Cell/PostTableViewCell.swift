//
//  PostTableViewCell.swift
//  BuyOrNot
//
//  Created by ungQ on 4/19/24.
//

import UIKit
import SnapKit
import RxSwift
import Lottie

class PostTableViewCell: UITableViewCell {

	var disposeBag = DisposeBag()

	let profileImageView = UIImageView()
	let usernameLabel = UILabel()
	let postImageView = UIImageView()
	let likeButton = UIButton(type: .system)
	let dislikeButton = UIButton(type: .system)

	let commentButton = UIButton(type: .system)
	let titleNPriceLabel = UILabel()
	let likeLabel = UILabel()
	let dislikeLabel = UILabel()
	let timeLabel = UILabel()

	var like = false
	var dislike = false

	let likeDislikeProgressView = UIProgressView(progressViewStyle: .default)

	let deleteButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "trash"), for: .normal)
		button.tintColor = .systemRed
		return button
	}()

	override func prepareForReuse() {
		super.prepareForReuse()
//		likeButton.transform = CGAffineTransform.identity
//		  dislikeButton.transform = CGAffineTransform.identity
//		likeButton.alpha = 1
//		 dislikeButton.alpha = 1
//		likeButton.removeTarget(nil, action: nil, for: .allEvents)
//		   dislikeButton.removeTarget(nil, action: nil, for: .allEvents)
//
		profileImageView.image = UIImage(systemName: "person.circle.fill")
//		usernameLabel.text = ""
//		likeLabel.text = ""
//		dislikeLabel.text = ""
//		timeLabel.text = ""
//
//
		likeDislikeProgressView.isHidden = true
		likeLabel.isHidden = true
		dislikeLabel.isHidden = true
//		likeLabel.alpha = 1
//		dislikeLabel.alpha = 1
//			likeDislikeProgressView.trackTintColor = .systemGray4
//			likeDislikeProgressView.progressTintColor = .systemBlue


		disposeBag = DisposeBag()

	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		contentView.addSubview(profileImageView)
		contentView.addSubview(usernameLabel)
		contentView.addSubview(postImageView)
		contentView.addSubview(likeButton)
		contentView.addSubview(dislikeButton)

		contentView.addSubview(commentButton)
		contentView.addSubview(titleNPriceLabel)
		contentView.addSubview(likeLabel)
		contentView.addSubview(timeLabel)
		contentView.addSubview(likeDislikeProgressView)

		contentView.addSubview(dislikeLabel)
		contentView.addSubview(deleteButton)

		setupViews()
		setupConstraints()
//		configureMenu()

		likeDislikeProgressView.isHidden = true
		likeLabel.isHidden = true
		dislikeLabel.isHidden = true

	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	private func setupViews() {

		profileImageView.contentMode = .scaleAspectFill
		profileImageView.layer.cornerRadius = 15
		profileImageView.clipsToBounds = true
		profileImageView.image = UIImage(systemName: "person.circle.fill")

		usernameLabel.font = .systemFont(ofSize: 14, weight: .bold)

		postImageView.contentMode = .scaleAspectFill
		postImageView.clipsToBounds = true


		likeButton.setImage(UIImage(systemName: "hand.thumbsup.circle"), for: .normal)
		dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown.circle"), for: .normal)

		commentButton.setImage(UIImage(systemName: "message"), for: .normal)

		titleNPriceLabel.font = .systemFont(ofSize: 14, weight: .bold)
		titleNPriceLabel.textAlignment = .center
		likeLabel.font = .systemFont(ofSize: 14)
		likeLabel.numberOfLines = 0
		dislikeLabel.font = .systemFont(ofSize: 14)
		dislikeLabel.numberOfLines = 0

		timeLabel.font = .systemFont(ofSize: 12)
		timeLabel.textColor = .gray


		likeDislikeProgressView.progressTintColor = .systemBlue
		likeDislikeProgressView.trackTintColor = .systemRed
		likeDislikeProgressView.layer.cornerRadius = 12
		likeDislikeProgressView.layer.masksToBounds = true

	}
//	private func configureMenu() {
//		let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] _ in
//			self?.editPost()
//		}
//
//		let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { [weak self] _ in
//			self?.deletePost()
//		}
//
//		let menu = UIMenu(title: "", children: [editAction, deleteAction])
//		menuButton.menu = menu
//		menuButton.showsMenuAsPrimaryAction = true  // Ensure the menu is displayed when the button is tapped
//	}


	private func setupConstraints() {


		profileImageView.snp.makeConstraints { make in
			make.top.leading.equalToSuperview().offset(10)
			make.width.height.equalTo(30)
		}


		usernameLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(10)
			make.leading.equalTo(profileImageView.snp.trailing).offset(10)
		}

		postImageView.snp.makeConstraints { make in
			make.top.equalTo(profileImageView.snp.bottom).offset(10)
			make.horizontalEdges.equalToSuperview()
			make.height.equalTo(postImageView.snp.width)
		}

		likeButton.snp.makeConstraints { make in

			make.top.equalTo(postImageView.snp.bottom).offset(10)
			make.centerX.equalToSuperview().offset(-20)
			make.size.equalTo(25)
		}

		dislikeButton.snp.makeConstraints { make in
			make.top.equalTo(postImageView.snp.bottom).offset(10)
			make.centerX.equalToSuperview().offset(20)
			make.size.equalTo(25)
		}

		likeLabel.snp.makeConstraints { make in
			make.centerY.equalTo(likeButton)
			make.trailing.equalTo(likeButton.snp.leading).offset(-10)
		}

		dislikeLabel.snp.makeConstraints { make in
			make.centerY.equalTo(dislikeButton)
			make.leading.equalTo(dislikeButton.snp.trailing).offset(10)
		}

		commentButton.snp.makeConstraints { make in
			make.top.equalTo(postImageView.snp.bottom).offset(10)
			make.right.equalToSuperview().offset(-10)
			make.size.equalTo(25)
		}

		likeDislikeProgressView.snp.makeConstraints { make in
			make.bottom.equalTo(postImageView.snp.bottom).offset(-5)
			make.left.right.equalToSuperview().inset(10)
			make.height.equalTo(32)
		}

		titleNPriceLabel.snp.makeConstraints { make in
			make.top.equalTo(likeButton.snp.bottom).offset(4)
			make.horizontalEdges.equalToSuperview().inset(10)
			make.bottom.equalToSuperview().offset(-10).priority(750)
		}

		timeLabel.snp.makeConstraints { make in
			make.top.equalTo(usernameLabel.snp.bottom)
			make.leading.equalTo(profileImageView.snp.trailing).offset(10)

		}

		deleteButton.snp.makeConstraints { make in
			make.bottom.equalTo(postImageView.snp.top).offset(-10)
			  make.trailing.equalToSuperview().inset(10)
			  make.height.equalTo(25)
			  make.width.equalTo(deleteButton.snp.height)
		}
	}

//	func animateButton(_ button: UIButton) {
//		DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//			UIView.animate(withDuration: 0.2, animations: {
//				// Scale up the button image
//				button.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
//				button.alpha = 0.5  // Slightly fade the button to see the effect
//			}) { _ in
//				UIView.animate(withDuration: 0.1, animations: {
//					// Return to normal size but keep invisible
//					button.transform = CGAffineTransform.identity
//					button.alpha = 0
//				}) { _ in
//					// Ensure visibility is restored after animation
//					button.alpha = 1
//				}
//			}
//		}
//	}
}

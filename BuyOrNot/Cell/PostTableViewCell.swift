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

	var leftTap = {}
	var rightTap = {}

	let likeDislikeProgressView = UIProgressView(progressViewStyle: .default)

	override func prepareForReuse() {
		super.prepareForReuse()

		likeButton.transform = CGAffineTransform.identity
		dislikeButton.transform = CGAffineTransform.identity
		likeButton.alpha = 1
		dislikeButton.alpha = 1
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

		likeButton.rx.tap
			.subscribe(with: self) { owner, _ in
				owner.animateButton(owner.likeButton, shouldFill: !(owner.likeButton.isSelected))
				owner.likeButton.isSelected = !(owner.likeButton.isSelected)  // Toggle the selected state to track the icon status
			}
			.disposed(by: disposeBag)


		dislikeButton.rx.tap
			.subscribe(with: self) { owner, _ in
				owner.animateButton(owner.dislikeButton, shouldFill: !(owner.dislikeButton.isSelected))
				owner.dislikeButton.isSelected = !(owner.dislikeButton.isSelected)
			}
			.disposed(by: disposeBag)
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


		likeButton.setImage(UIImage(systemName: "hand.thumbsup.circle"), for: .normal)
		dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown.circle"), for: .normal)

		bookmarkButton.setImage(UIImage(systemName: "message"), for: .normal)

		likesLabel.font = .systemFont(ofSize: 14, weight: .bold)
		captionLabel.font = .systemFont(ofSize: 14)
		captionLabel.numberOfLines = 0

		timeLabel.font = .systemFont(ofSize: 12)
		timeLabel.textColor = .gray


		likeDislikeProgressView.progressTintColor = .systemBlue
		likeDislikeProgressView.trackTintColor = .systemRed
		likeDislikeProgressView.layer.cornerRadius = 12
		likeDislikeProgressView.layer.masksToBounds = true

		postImageView.isUserInteractionEnabled = true
		let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTap))
		imageTapGesture.numberOfTapsRequired = 2
		postImageView.addGestureRecognizer(imageTapGesture)



	}

	@objc private func imageTap(gesture: UITapGestureRecognizer) {
		let touchPoint = gesture.location(in: gesture.view)
		let width = gesture.view?.bounds.width ?? 0
		let targetButton = touchPoint.x < width / 2 ? likeButton : dislikeButton

		// Determine whether to fill or unfill the icon based on the current image
		let shouldFill = targetButton.currentImage == UIImage(systemName: "hand.thumbsup") || targetButton.currentImage == UIImage(systemName: "hand.thumbsdown")

		animateButton(targetButton, shouldFill: shouldFill)

			// Execute the appropriate tap action
			if touchPoint.x < width / 2 {
				leftTap()
			} else {
				rightTap()
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


		bookmarkButton.snp.makeConstraints { make in
			make.top.equalTo(postImageView.snp.bottom).offset(10)
			make.right.equalToSuperview().offset(-10)
			make.size.equalTo(25)
		}

		likeDislikeProgressView.snp.makeConstraints { make in
			make.bottom.equalTo(postImageView.snp.bottom).offset(-5)
			make.left.right.equalToSuperview().inset(10)
			make.height.equalTo(32)
//			make.bottom.equalToSuperview().offset(-10).priority(750)
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

	func animateButton(_ button: UIButton, shouldFill: Bool) {
		let iconName = shouldFill ? "hand.thumbsup.fill" : "hand.thumbsup"  // Decide the icon based on shouldFill
		  let initialScale = CGAffineTransform(scaleX: 1.5, y: 1.5)  // Initial scale for animation

		  UIView.animate(withDuration: 0.2, animations: {
			  button.transform = initialScale  // Scale up
		  }) { _ in
			  UIView.animate(withDuration: 0.1, animations: {
				  button.transform = CGAffineTransform.identity  // Scale down
				  button.alpha = 0  // Begin to fade out
			  }) { _ in
				  // Cross-dissolve transition for the image change
				  UIView.transition(with: button, duration: 0.1, options: .transitionCrossDissolve, animations: {
					  button.setImage(UIImage(systemName: iconName), for: .normal)
				  }) { _ in
					  button.alpha = 1  // Restore visibility
				  }
			  }
		  }
	  }
}

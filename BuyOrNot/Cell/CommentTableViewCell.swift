//
//  CommentTableViewCell.swift
//  BuyOrNot
//
//  Created by ungQ on 4/22/24.
//

import UIKit
import SnapKit
import RxSwift

class CommentTableViewCell: UITableViewCell {

	var disposeBag = DisposeBag()

	let profileImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.layer.cornerRadius = 20
		imageView.clipsToBounds = true
		imageView.image = UIImage(systemName: "person.crop.circle") // Placeholder image
		return imageView
	}()

	let nicknameLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
		return label
	}()

	let dateLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 12)
		label.textColor = .gray
		return label
	}()

	let commentLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14)
		label.numberOfLines = 0
		return label
	}()

	let editButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "pencil"), for: .normal)
		button.tintColor = .systemBlue
		return button
	}()

	let deleteButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "trash"), for: .normal)
		button.tintColor = .systemRed
		return button
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(profileImageView)
		contentView.addSubview(nicknameLabel)
		contentView.addSubview(dateLabel)
		contentView.addSubview(commentLabel)
		contentView.addSubview(editButton)
		contentView.addSubview(deleteButton)
		setupConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupConstraints() {
		profileImageView.snp.makeConstraints { make in
			make.top.left.equalToSuperview().inset(10)
			make.size.equalTo(30)
		}

		nicknameLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().inset(10)
			make.left.equalTo(profileImageView.snp.right).offset(10)
		}

		dateLabel.snp.makeConstraints { make in
			make.bottom.equalTo(nicknameLabel.snp.bottom)
			make.left.equalTo(nicknameLabel.snp.right).offset(10)
		}

		deleteButton.snp.makeConstraints { make in
			make.top.equalToSuperview().inset(10)
			  make.trailing.equalToSuperview().inset(10)
			  make.height.equalTo(20)
			  make.width.equalTo(deleteButton.snp.height)
		}

		editButton.snp.makeConstraints { make in
			make.top.equalToSuperview().inset(10)
			  make.trailing.equalTo(deleteButton.snp.leading).offset(-10)
			  make.height.equalTo(deleteButton.snp.height)
			  make.width.equalTo(editButton.snp.height)
		}



		commentLabel.snp.makeConstraints { make in
			make.top.equalTo(nicknameLabel.snp.bottom).offset(10)
			make.leading.equalTo(profileImageView.snp.trailing).offset(10)
			make.trailing.equalToSuperview().offset(-10)
			make.bottom.equalToSuperview().offset(-10)
		}

	}

//	func configure(with comment: Comment) {
//		nicknameLabel.text = comment.nickname
//		dateLabel.text = comment.date
//		commentLabel.text = comment.text
//	}
}

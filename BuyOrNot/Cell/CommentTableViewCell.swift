//
//  CommentTableViewCell.swift
//  BuyOrNot
//
//  Created by ungQ on 4/22/24.
//

import UIKit
import SnapKit

class CommentTableViewCell: UITableViewCell {


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
		label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		return label
	}()

	let dateLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14)
		label.textColor = .gray
		return label
	}()

	let commentLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14)
		label.numberOfLines = 0 // Allows for multiline text
		return label
	}()

	let editButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Edit", for: .normal)
		return button
	}()

	let deleteButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Delete", for: .normal)
		button.setTitleColor(.red, for: .normal)
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
			make.size.equalTo(40)
		}

		nicknameLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().inset(10)
			make.left.equalTo(profileImageView.snp.right).offset(10)
		}

		dateLabel.snp.makeConstraints { make in
			make.top.equalTo(nicknameLabel.snp.bottom).offset(2)
			make.left.equalTo(profileImageView.snp.right).offset(10)
		}

		commentLabel.snp.makeConstraints { make in
			make.top.equalTo(profileImageView.snp.bottom).offset(10)
			make.left.right.equalToSuperview().inset(10)
		}

		editButton.snp.makeConstraints { make in
			make.top.equalTo(commentLabel.snp.bottom).offset(10)
			make.right.equalTo(deleteButton.snp.left).offset(-10)
			make.bottom.equalToSuperview().inset(10)
		}

		deleteButton.snp.makeConstraints { make in
			make.top.equalTo(commentLabel.snp.bottom).offset(10)
			make.right.equalToSuperview().inset(10)
			make.bottom.equalToSuperview().inset(10)
		}
	}

//	func configure(with comment: Comment) {
//		nicknameLabel.text = comment.nickname
//		dateLabel.text = comment.date
//		commentLabel.text = comment.text
//	}
}

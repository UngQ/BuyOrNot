//
//  FollowTableViewCell.swift
//  BuyOrNot
//
//  Created by ungQ on 4/30/24.
//

import UIKit
import RxSwift

class FollowTableViewCell: UITableViewCell {

	var disposeBag = DisposeBag()


	 let profileImageView: UIImageView = {
		 let imageView = UIImageView()
		 imageView.contentMode = .scaleAspectFill
		 imageView.clipsToBounds = true
		 imageView.layer.cornerRadius = 20
		 imageView.image = UIImage(systemName: "person.circle.fill")
		 return imageView
	 }()

	 let nicknameLabel: UILabel = {
		 let label = UILabel()
		 label.font = UIFont.systemFont(ofSize: 16)
		 label.textColor = .darkGray
		 return label
	 }()

	 let followButton: UIButton = {
		 let button = UIButton(type: .system)
		 button.setTitle("Follow", for: .normal)
		 button.layer.borderWidth = 1
		 button.layer.borderColor = UIColor.blue.cgColor
		 button.layer.cornerRadius = 5
		 return button
	 }()

	 override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		 super.init(style: style, reuseIdentifier: reuseIdentifier)
		 setupViews()
	 }

	 required init?(coder: NSCoder) {
		 fatalError("init(coder:) has not been implemented")
	 }

	 private func setupViews() {
		 contentView.addSubview(profileImageView)
		 contentView.addSubview(nicknameLabel)
		 contentView.addSubview(followButton)

		 profileImageView.snp.makeConstraints { make in
			 make.left.equalTo(contentView.snp.left).offset(16)
			 make.centerY.equalTo(contentView.snp.centerY)
			 make.width.height.equalTo(40)
		 }

		 nicknameLabel.snp.makeConstraints { make in
			 make.left.equalTo(profileImageView.snp.right).offset(10)
			 make.centerY.equalTo(contentView.snp.centerY)
		 }

		 followButton.snp.makeConstraints { make in
			 make.right.equalTo(contentView.snp.right).offset(-16)
			 make.centerY.equalTo(contentView.snp.centerY)
			 make.width.equalTo(80)
			 make.height.equalTo(30)
		 }
	 }
}

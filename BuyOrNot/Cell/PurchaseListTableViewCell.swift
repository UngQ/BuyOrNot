//
//  PurchaseListTableViewCell.swift
//  BuyOrNot
//
//  Created by ungQ on 5/5/24.
//

import UIKit
import SnapKit

class PurchaseListTableViewCell: UITableViewCell {

	let nameLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16)
		label.textColor = .black
		return label
	}()

	let priceLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14)
		label.textColor = .gray
		return label
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(nameLabel)
		contentView.addSubview(priceLabel)
		setupConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupConstraints() {
		nameLabel.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(20)
			make.top.equalToSuperview().offset(10)
			make.bottom.equalToSuperview().offset(-10)
		}

		priceLabel.snp.makeConstraints { make in
			make.leading.equalTo(nameLabel.snp.trailing).offset(10)
			make.trailing.equalToSuperview().offset(-20)
			make.centerY.equalTo(nameLabel.snp.centerY)
		}
	}
}

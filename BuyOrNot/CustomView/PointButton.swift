//
//  PointButton.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import UIKit

class PointButton: UIButton {

	init(title: String) {
		super.init(frame: .zero)

		setTitle(title, for: .normal)
		setTitleColor(Color.white, for: .normal)
		backgroundColor = .lightGray
		layer.cornerRadius = 10
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}

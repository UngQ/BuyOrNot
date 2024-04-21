//
//  UICollectionViewFlowLayout+Ex.swift
//  BuyOrNot
//
//  Created by ungQ on 4/21/24.
//

import UIKit

extension UICollectionViewFlowLayout {
	static func createThreeColumnFlowLayout(in view: UIView) -> UICollectionViewFlowLayout {
		let layout = UICollectionViewFlowLayout()
		let width = view.bounds.width / 3 - 1
		layout.itemSize = CGSize(width: width, height: width)
		layout.minimumLineSpacing = 1
		layout.minimumInteritemSpacing = 0
		return layout
	}
}

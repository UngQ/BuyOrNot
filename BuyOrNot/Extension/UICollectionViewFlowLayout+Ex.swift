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


	static func createCompositionLayout(in view: UIView) -> UICollectionViewCompositionalLayout {
//		let fullPhotoItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(2/3)))
//			fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)

		let mainItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/3), heightDimension: .fractionalHeight(1.0)))
		mainItem.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
		let pairItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5)))
		pairItem.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)


		let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1.0)), repeatingSubitem: pairItem, count: 2)

		let mainWithTrailingGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(4/9)), subitems: [mainItem, trailingGroup])

		let tripleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1.0)))
		tripleItem.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)

		let tripleGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(2/9)), repeatingSubitem: tripleItem, count: 3)

		let mainWithReversedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(4/9)), subitems: [trailingGroup, mainItem])

		let nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(16/9)), subitems: [mainWithTrailingGroup, tripleGroup, mainWithReversedGroup])

		let section = NSCollectionLayoutSection(group: nestedGroup)

		let layout = UICollectionViewCompositionalLayout(section: section)

		return layout
	}
}

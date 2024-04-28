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

		let mainItem = NSCollectionLayoutItem(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(2/3),
				heightDimension: .fractionalWidth(2/3)
			)
		)
		mainItem.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)


		let pairItem = NSCollectionLayoutItem(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .fractionalWidth(1.0)
			)
		)
		pairItem.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)


		let trailingGroup = NSCollectionLayoutGroup.vertical(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1/3),
				heightDimension: .fractionalWidth(2/3)
			),
			repeatingSubitem: pairItem, count: 2
		)


		let mainWithTrailingGroup = NSCollectionLayoutGroup.horizontal(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .fractionalWidth(2/3)
			),
			subitems: [mainItem, trailingGroup]
		)

		let tripleItem = NSCollectionLayoutItem(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1/3),
				heightDimension: .fractionalWidth(1/3)
			)
		)
		tripleItem.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)


		let tripleGroup = NSCollectionLayoutGroup.horizontal(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .fractionalWidth(1/3)
			),
			repeatingSubitem: tripleItem, count: 3
		)


		let nestedGroup = NSCollectionLayoutGroup.vertical(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .fractionalWidth(1.0) 
			), subitems: [mainWithTrailingGroup, tripleGroup]
		)

		let section = NSCollectionLayoutSection(group: nestedGroup)
		let layout = UICollectionViewCompositionalLayout(section: section)
		return layout

	}
}

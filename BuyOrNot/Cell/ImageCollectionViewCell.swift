//
//  ImageCollectionViewCell.swift
//  BuyOrNot
//
//  Created by ungQ on 4/20/24.
//

import UIKit
import RxSwift

class ImageCollectionViewCell: UICollectionViewCell {
	
	var disposeBag = DisposeBag()

	let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		return imageView
	}()

	override func prepareForReuse() {
		super.prepareForReuse()
		
		disposeBag = DisposeBag()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.addSubview(imageView)
		imageView.frame = contentView.bounds
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func configure(with image: UIImage) {
		imageView.image = image
	}
}

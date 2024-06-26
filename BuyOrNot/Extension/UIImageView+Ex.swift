//
//  UIImageView+Ex.swift
//  BuyOrNot
//
//  Created by ungQ on 4/20/24.
//

import UIKit
import Kingfisher

extension UIImageView {

	func loadImage(from urlString: String, placeholder: UIImage? = UIImage(systemName: "person.circle.fill")) {
		guard let url = URL(string: urlString) else {

			self.image = placeholder
			return
		}
		self.kf.indicatorType =  .activity
		self.kf.setImage(
			with: url,
			options: [.requestModifier(NetworkManager.imageDownloadRequest)],
			completionHandler:  { [weak self] result in
				DispatchQueue.main.async {
					switch result {
					case .success(let value):
						self?.image = value.image
					case .failure(let error):
						print("Error setting image: \(error)")
						self?.image = placeholder
					}
				}
			}
		)

	}
}

struct ImageLoader {
	static func loadImage(from urlString: String, placeholder: UIImage? = UIImage(systemName: "person.circle.fill"), completion: @escaping (UIImage?) -> Void) {
		guard let url = URL(string: urlString) else {
			completion(placeholder)
			return
		}
		KingfisherManager.shared.retrieveImage(with: url, options: [.requestModifier(NetworkManager.imageDownloadRequest)]) { result in
			DispatchQueue.main.async {
				switch result {
				case .success(let value):

					completion(value.image)
				case .failure(let error):
					print("Error downloading image: \(error)")
					completion(placeholder)
				}
			}
		}
	}
}

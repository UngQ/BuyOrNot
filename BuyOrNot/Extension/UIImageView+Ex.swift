//
//  UIImageView+Ex.swift
//  BuyOrNot
//
//  Created by ungQ on 4/20/24.
//

import UIKit
import Kingfisher

extension UIImageView {
	/// Loads an image from a URL string, with a default placeholder for errors.
	/// - Parameters:
	///   - urlString: The URL string of the image to be loaded.
	///   - placeholder: A UIImage to be used as a fallback when the image cannot be loaded.
	func loadImage(from urlString: String, placeholder: UIImage? = UIImage(systemName: "exclamationmark.triangle")) {
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

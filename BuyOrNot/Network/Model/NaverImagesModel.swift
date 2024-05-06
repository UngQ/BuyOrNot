//
//  NaverImagesModel.swift
//  BuyOrNot
//
//  Created by ungQ on 5/5/24.
//

import Foundation

struct NaverImagesModel: Codable {
	let lastBuildDate: String
	let total, start, display: Int
	let items: [NaverImageModel]
}

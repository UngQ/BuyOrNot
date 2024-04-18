//
//  PostQuery.swift
//  BuyOrNot
//
//  Created by ungQ on 4/15/24.
//

import Foundation

struct PostQuery: Encodable {
	let title: String
	let content: String //해시태그
	let content1: String //가격
//	let content2: String //마세요
	let product_id: String = "buyOrNot"
	let files: [String]
}

struct PostQueryItems {
	let next: String?
	let limit: String?
	let product_id = "buyOrNot"
}

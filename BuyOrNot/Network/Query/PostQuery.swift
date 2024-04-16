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
//	let content1: String //사세요 Int 활용
//	let content2: String //마세요
	let product_id: String = "buyOrNot"
	let files: Array<String>
}

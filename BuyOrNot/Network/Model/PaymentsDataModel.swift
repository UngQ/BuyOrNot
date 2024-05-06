//
//  PaymentsDataModel.swift
//  BuyOrNot
//
//  Created by ungQ on 5/5/24.
//

import Foundation

struct PaymentsDataModel: Decodable, Equatable {
	let payment_id: String
	let buyer_id: String
	let post_id: String
	let merchant_uid: String
	let productName: String
	let price: Int
	let paidAt: String

	static func == (lhs: PaymentsDataModel, rhs: PaymentsDataModel) -> Bool {
		return lhs.payment_id == rhs.payment_id
	 }
}

//
//  String+Ex.swift
//  BuyOrNot
//
//  Created by ungQ on 4/21/24.
//

import Foundation

extension String {

	func formattedDate() -> String {
		let isoFormatter = ISO8601DateFormatter()
		isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

		guard let date = isoFormatter.date(from: self) else {
			return "Invalid date"
		}

		if Calendar.current.isDateInToday(date) {
			let relativeFormatter = DateComponentsFormatter()
			relativeFormatter.allowedUnits = [.hour, .minute]
			relativeFormatter.unitsStyle = .full
			relativeFormatter.maximumUnitCount = 1
			relativeFormatter.calendar?.locale = Locale(identifier: "ko_KR")

			if let relativeString = relativeFormatter.string(from: date, to: Date()) {
				return relativeString + " 전"
			}
		}

		let customFormatter = DateFormatter()
		customFormatter.locale = Locale(identifier: "ko_KR")
		customFormatter.dateFormat = "yyyy년 MM월 dd일"
		return customFormatter.string(from: date)
	}
}

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

		let calendar = Calendar.current

		// Check if the date is within today.
		if calendar.isDateInToday(date) {
			let now = Date()
			let components = calendar.dateComponents([.hour, .minute], from: date, to: now)

			// Check if the date is 'right now'.
			if components.minute == 0 {
				return "방금"
			} else {
				let relativeFormatter = DateComponentsFormatter()
				relativeFormatter.allowedUnits = [.hour, .minute]
				relativeFormatter.unitsStyle = .full
				relativeFormatter.maximumUnitCount = 1
				relativeFormatter.calendar?.locale = Locale(identifier: "ko_KR")

				if let relativeString = relativeFormatter.string(from: date, to: now) {
					return relativeString + " 전"
				}
			}
		}

		let customFormatter = DateFormatter()
		customFormatter.locale = Locale(identifier: "ko_KR")
		customFormatter.dateFormat = "yyyy년 MM월 dd일"
		return customFormatter.string(from: date)
	}
}

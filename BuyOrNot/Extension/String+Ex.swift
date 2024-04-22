//
//  String+Ex.swift
//  BuyOrNot
//
//  Created by ungQ on 4/21/24.
//

import Foundation

//extension String {
//	/// Converts an ISO 8601 date string to a formatted string "YYYY년 MM월 dd일".
//	func formattedDate() -> String {
//		let isoFormatter = ISO8601DateFormatter()
//		isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Handle fractional seconds
//
//		// Parse the date from the string
//		guard let date = isoFormatter.date(from: self) else {
//			return "Invalid date"
//		}
//
//		let customFormatter = DateFormatter()
//		customFormatter.locale = Locale(identifier: "ko_KR") // Korean locale for year, month, and day suffixes
//		customFormatter.dateFormat = "yyyy년 MM월 dd일"
//
//		// Format and return the new date string
//		return customFormatter.string(from: date)
//	}
//}

extension String {
	/// Converts an ISO 8601 date string to a relative time string or a formatted date string.
	func formattedDate() -> String {
		let isoFormatter = ISO8601DateFormatter()
		isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Support for fractional seconds

		// Parse the date from the string
		guard let date = isoFormatter.date(from: self) else {
			return "Invalid date"
		}

		// Check if the date is today and return a relative time string if true
		if Calendar.current.isDateInToday(date) {
			let relativeFormatter = DateComponentsFormatter()
			relativeFormatter.allowedUnits = [.hour, .minute]
			relativeFormatter.unitsStyle = .full
			relativeFormatter.maximumUnitCount = 1  // Only show the largest unit

			if let relativeString = relativeFormatter.string(from: date, to: Date()) {
				return relativeString + " 전"
			}
		}

		// Otherwise, format and return the date in full format
		let customFormatter = DateFormatter()
		customFormatter.locale = Locale(identifier: "ko_KR") // Set locale to Korean
		customFormatter.dateFormat = "yyyy년 MM월 dd일"
		return customFormatter.string(from: date)
	}
}

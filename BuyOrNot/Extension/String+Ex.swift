//
//  String+Ex.swift
//  BuyOrNot
//
//  Created by ungQ on 4/21/24.
//

import Foundation

extension String {
	/// Converts an ISO 8601 date string to a formatted string "YYYY년 MM월 dd일".
	func formattedDate() -> String {
		let isoFormatter = ISO8601DateFormatter()
		isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Handle fractional seconds

		// Parse the date from the string
		guard let date = isoFormatter.date(from: self) else {
			return "Invalid date"
		}

		let customFormatter = DateFormatter()
		customFormatter.locale = Locale(identifier: "ko_KR") // Korean locale for year, month, and day suffixes
		customFormatter.dateFormat = "yyyy년 MM월 dd일"

		// Format and return the new date string
		return customFormatter.string(from: date)
	}
}

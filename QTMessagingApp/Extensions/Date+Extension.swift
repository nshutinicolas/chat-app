//
//  Date+Extension.swift
//  QTMessagingApp
//
//  Created by Musoni nshuti Nicolas on 24/09/2026.
//

import Foundation

extension Date {
	func removing(minutes: Int) -> Date {
		Calendar.current.date(byAdding: .minute, value: -minutes, to: self) ?? self
	}
	
	func chatFormatted() -> String {
		let calendar = Calendar.current
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = .current
		if calendar.isDateInToday(self) {
			dateFormatter.dateFormat = "HH:mm"
			return dateFormatter.string(from: self)
		} else if calendar.isDateInYesterday(self) {
			return "Yesterday"
		} else {
			dateFormatter.dateFormat = "dd/MM"
			return dateFormatter.string(from: self)
		}
	}
	
	/// This will produce: "2026-04-07T18:57:59Z"
	var iSOTimestamp: String {
		let formatter = ISO8601DateFormatter()
		return formatter.string(from: self)
	}
}

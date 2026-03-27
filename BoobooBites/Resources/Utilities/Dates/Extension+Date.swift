//
//  Extension+Date.swift
//  BoobooBites
//
//  Created by Ryan Rook on 21/03/2026.
//

import SwiftUI

extension Date {
	
	func currentMonth() -> Int {
		let calendar = Calendar.current
		let month = calendar.component(.month, from: self)
		return month
	}
	
	func currentYear() -> Int {
		let calendar = Calendar.current
		let year = calendar.component(.year, from: self)
		return year
	}
	
	func startOfMonth(for date: Date) -> Date {
		let calendar = Calendar.current
		let components = calendar.dateComponents([.year, .month], from: date)
		return calendar.date(from: components)!
	}
}

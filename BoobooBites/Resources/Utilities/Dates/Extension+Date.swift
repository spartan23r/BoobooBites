//
//  Extension+Date.swift
//  BoobooBites
//
//  Created by Ryan Rook on 21/03/2026.
//

import SwiftUI

extension Date {
	var month: Int {
		AppCalendar.shared.component(.month, from: self)
	}
	
	var year: Int {
		AppCalendar.shared.component(.year, from: self)
	}
	
	var startOfMonth: Date {
		let calendar = AppCalendar.shared
		let components = calendar.dateComponents([.year, .month], from: self)
		return calendar.date(from: components) ?? self
	}
	
	var startOfWeek: Date {
		let calendar = AppCalendar.shared
		return calendar.dateInterval(of: .weekOfYear, for: self)?.start ?? self
	}
	
	var startOfDay: Date {
		let calendar = AppCalendar.shared
		return calendar.dateInterval(of: .day, for: self)?.start ?? self
	}
	
	func addingMonths(_ value: Int) -> Date {
		AppCalendar.shared.date(byAdding: .month, value: value, to: self) ?? self
	}
	
	func addingMonths(_ value: Int, using calendar: Calendar) -> Date {
		calendar.date(byAdding: .month, value: value, to: self) ?? self
	}
	
	func addingWeeks(_ value: Int) -> Date {
		AppCalendar.shared.date(byAdding: .weekOfYear, value: value, to: self) ?? self
	}
	
	func addingWeeks(_ value: Int, using calendar: Calendar) -> Date {
		calendar.date(byAdding: .weekOfYear, value: value, to: self) ?? self
	}
	
	func addingDays(_ value: Int) -> Date {
		AppCalendar.shared.date(byAdding: .day, value: value, to: self) ?? self
	}
	
	func addingDays(_ value: Int, using calendar: Calendar) -> Date {
		calendar.date(byAdding: .day, value: value, to: self) ?? self
	}
	
	func isInSameWeek(as date: Date, using calendar: Calendar) -> Bool {
		calendar.isDate(self, equalTo: date, toGranularity: .weekOfYear) &&
		calendar.component(.yearForWeekOfYear, from: self) ==
		calendar.component(.yearForWeekOfYear, from: date)
	}
	
	func isInSameDay(as date: Date) -> Bool {
		self.startOfDay == date.startOfDay
	}
}

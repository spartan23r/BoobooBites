//
//  AppCalendar.swift
//  BoobooBites
//
//  Created by Ryan Rook on 28/03/2026.
//

import Foundation

enum AppCalendar {
	
	static var shared: Calendar {
		var calendar = Calendar(identifier: .gregorian)
		calendar.locale = Locale.current
		calendar.timeZone = TimeZone.current
		calendar.firstWeekday = 2 // Monday
		calendar.minimumDaysInFirstWeek = 4
		return calendar
	}
}

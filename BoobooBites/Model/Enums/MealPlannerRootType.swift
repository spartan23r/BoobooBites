//
//  MealPlannerRootType.swift
//  BoobooBites
//
//  Created by Ryan Rook on 23/03/2026.
//

import SwiftUI

enum MealPlannerRootType: Int, Codable {
	case month
	case week
	case list
	
	var title: String {
		switch self {
		case .month: "Month"
		case .week: "Week"
		case .list: "List"
		}
	}
	
	var image: String {
		switch self {
		case .month: "list.bullet.below.rectangle"
		case .week: "calendar.day.timeline.left"
		case .list: "list.dash"
		}
	}
}

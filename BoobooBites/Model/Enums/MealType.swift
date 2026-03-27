//
//  MealType.swift
//  BoobooBites
//
//  Created by Ryan Rook on 21/03/2026.
//

import SwiftUI

enum MealType: String, CaseIterable, Codable {
	case breakfast
	case lunch
	case dinner
	case snack
	
	var sortOrder: Int {
		switch self {
		case .breakfast: 0
		case .lunch: 1
		case .dinner: 2
		case .snack: 3
		}
	}
	
	var image: some View {
		switch self {
		case .breakfast: Image(systemName: "sunrise.fill")/*.foregroundStyle(self.color.gradient)*/
		case .lunch: Image(systemName: "sun.max.fill")/*.foregroundStyle(self.color.gradient)*/
		case .dinner: Image(systemName: "moon.fill")/*.foregroundStyle(self.color.gradient)*/
		case .snack: Image(systemName: "leaf.fill")/*.foregroundStyle(self.color.gradient)*/
		}
	}
	
	var color: Color {
		switch self {
		case .breakfast: Color(.tailsOrange)
		case .lunch: Color(.sonicYellow)
		case .dinner: Color(.sonicPurple)
		case .snack: Color(.sonicGreen)
		}
	}
}

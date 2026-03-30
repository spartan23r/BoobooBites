//
//  AnalyticsUtils.swift
//  BoobooBites
//
//  Created by Ryan Rook on 30/03/2026.
//

import SwiftUI
import FirebaseAnalytics

struct AnalyticsUtils {
	
	static func logButtonTap(screen: AnalyticsUtils.Screens, button: AnalyticsUtils.ButtonEvents) {
		Analytics.logEvent(
			"button_tap",
			parameters: [
				"screen": screen,
				"button": button
			]
		)
	}
	
}

extension AnalyticsUtils {
	
	enum Screens: String {
		case recipeAdd
		case recipeItem
		case ingredientList
		case ingredientAdd
		case ingredientItem
		case mealPlanAdd
		case mealPlanItem
	}
	
	enum ButtonEvents: String {
		case save
		case edit
		case delete
		case deleteAll
		case copyNotes
		case copyInstructions
	}
	
}

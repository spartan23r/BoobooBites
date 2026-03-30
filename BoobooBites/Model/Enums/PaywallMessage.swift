//
//  PaywallMessage.swift
//  BoobooBites
//
//  Created by Ryan Rook on 26/03/2026.
//

import SwiftUI

enum PaywallMessage {
	case ingredients, recipes, mealplans
	
	var title: String {
		switch self {
		case .ingredients: "Ingredients limit reached"
		case .recipes: "Recipes limit reached"
		case .mealplans: "Meal Plans limit reached"
		}
	}
	
	var description: String {
		switch self {
		case .ingredients: "You’ve reached the free limit of 25 ingredients. Upgrade to keep your full pantry in one place."
		case .recipes: "You’ve reached the free limit of 7 recipes. Upgrade to build your personal cookbook without limits."
		case .mealplans: "You’ve reached the free limit of 14 meal plans. Upgrade to plan your meals without limits or stress."
		}
	}
	
	var paywallDescription: String {
		switch self {
		case .ingredients: "Save all your ingredients in one place"
		case .recipes: "Create and keep unlimited recipes"
		case .mealplans: "Plan meals without limits or stress"
		}
	}
	
	var paywallImage: String {
		switch self {
		case .ingredients: "carrot"
		case .recipes: "fork.knife"
		case .mealplans: "calendar"
		}
	}
}

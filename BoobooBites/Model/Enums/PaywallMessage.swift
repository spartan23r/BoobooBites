//
//  GetPlusPaywallInformation.swift
//  BoobooBites
//
//  Created by Ryan Rook on 26/03/2026.
//

import SwiftUI

enum PaywallMessage {
	case ingredients, recipes, mealplans
	
	var title: String {
		switch self {
		case .ingredients: "Ingredient limit"
		case .recipes: "Recipe limit"
		case .mealplans: "Meal Plan limit"
		}
	}
	
	var description: String {
		switch self {
		case .ingredients: "You can save up to 12 ingredients for free. Upgrade to keep your full pantry in one place."
		case .recipes: "You can create up to 3 recipes for free. Upgrade to build your personal cookbook without limits."
		case .mealplans: "You can create up to 14 meal plans for free. Upgrade to plan your meals without limits or stress."
		}
	}
}

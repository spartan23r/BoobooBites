//
//  Ingredient.swift
//  BoobooBites
//
//  Created by Ryan Rook on 20/03/2026.
//

import SwiftUI
import SwiftData

@Model
final class Ingredient {
	
	var id = UUID()
	var name = String()
	var notes: String? = nil
	var color: String = "appleRed"
	var defaultUnit: UnitType = UnitType.grams
	
	@Relationship(deleteRule: .cascade, inverse: \RecipeIngredient.ingredient) var recipeIngredients: [RecipeIngredient] = []
	
	init(id: UUID = UUID(), name: String = String(), notes: String? = nil, color: String = "appleRed", defaultUnit: UnitType = .grams) {
		self.id = id
		self.name = name
		self.notes = notes
		self.color = color
		self.defaultUnit = defaultUnit
	}
}

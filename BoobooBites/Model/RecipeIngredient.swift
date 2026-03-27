//
//  RecipeIngredient.swift
//  BoobooBites
//
//  Created by Ryan Rook on 20/03/2026.
//

import SwiftUI
import SwiftData

@Model
final class RecipeIngredient: Identifiable {
	
	var id = UUID()
	var ingredient: Ingredient
	
	var amount: Double = Double()
	var unit: UnitType = UnitType.grams
	
	var note: String? = nil
	
	init(id: UUID = UUID(), ingredient: Ingredient, amount: Double = 1, unit: UnitType = .grams, note: String? = nil) {
		self.id = id
		self.ingredient = ingredient
		self.amount = amount
		self.unit = unit
		self.note = note
	}
}

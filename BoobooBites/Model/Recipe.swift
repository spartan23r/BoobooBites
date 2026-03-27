//
//  RecipeModel.swift
//  BoobooBites
//
//  Created by Ryan Rook on 20/03/2026.
//

import SwiftUI
import SwiftData

@Model
final class Recipe: Identifiable {
	
	var id = UUID()
	var name = String()
	var notes: String? = nil
	var instructions: String? = nil
	var prepTime: Int?  = nil // minutes
	var cookTime: Int? = nil // minutes
	var servings: Int? = nil // people
	var createdAt = Date()
	var updatedAt = Date()
	
	var ingredients: [RecipeIngredient]
	
	init(id: UUID, name: String, notes: String? = nil, instructions: String, prepTime: Int? = nil, cookTime: Int? = nil, servings: Int? = nil, createdAt: Date, updatedAt: Date) {
		self.id = id
		self.name = name
		self.notes = notes
		self.instructions = instructions
		self.prepTime = prepTime
		self.cookTime = cookTime
		self.servings = servings
		self.createdAt = createdAt
		self.updatedAt = updatedAt
	}
}

@Model
final class RecipeIngredient: Identifiable {
	
	var id = UUID()
	var ingredient: Ingredient
	
	var amount: Double = Double()
	var unit: UnitType
	
	var note: String? = nil
	
	init(id: UUID = UUID(), ingredient: Ingredient, amount: Double, unit: UnitType, note: String? = nil) {
		self.id = id
		self.ingredient = ingredient
		self.amount = amount
		self.unit = unit
		self.note = note
	}
}

@Model
final class Ingredient {
	
	var id = UUID()
	var name = String()
	var defaultUnit: UnitType? = nil
	
	init(id: UUID = UUID(), name: String, defaultUnit: UnitType? = nil) {
		self.id = id
		self.name = name
		self.defaultUnit = defaultUnit
	}
}

enum UnitType: String {
	case grams
	case kilograms
	case milliliters
	case liters
	case pieces
	case teaspoons
	case tablespoons
	case cups
}

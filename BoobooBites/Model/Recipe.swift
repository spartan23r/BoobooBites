//
//  Recipe.swift
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
	var notes = String()
	var color: String = "appleRed"
	var isFavorite: Bool = false
	var instructions = String()
	var prepTime: Int = 0 // minutes
	var cookTime: Int = 0 // minutes
	var servings: Int = 1 // persons
	var createdAt = Date()
	var lastUpdated = Date()
	
	var ingredients: [RecipeIngredient]
	
	@Relationship(deleteRule: .nullify, inverse: \MealPlan.recipe) var mealPlans: [MealPlan] = []
	
	init(id: UUID = UUID(), name: String = String(), notes: String = String(), color: String = "appleRed", isFavorite: Bool = false, instructions: String = String(), prepTime: Int = 0, cookTime: Int = 0, servings: Int = 1, createdAt: Date = Date(), lastUpdated: Date = Date(), ingredients: [RecipeIngredient]) {
		self.id = id
		self.name = name
		self.notes = notes
		self.color = color
		self.isFavorite = isFavorite
		self.instructions = instructions
		self.prepTime = prepTime
		self.cookTime = cookTime
		self.servings = servings
		self.createdAt = createdAt
		self.lastUpdated = lastUpdated
		self.ingredients = ingredients
	}
	
	var totalTime: Int {
		prepTime + cookTime
	}
	
	var ingredientCount: Int {
		ingredients.count
	}
}

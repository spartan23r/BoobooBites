//
//  MealPlan.swift
//  BoobooBites
//
//  Created by Ryan Rook on 21/03/2026.
//

import SwiftUI
import SwiftData

@Model
final class MealPlan {
	
	var id = UUID()
	var date = Date()
	var mealType: MealType = MealType.dinner
	var recipe: Recipe?
	var recipeName: String = ""
	var createdAt = Date()
	
	init(id: UUID = UUID(), date: Date = Date(), mealType: MealType = .dinner, recipe: Recipe?, createdAt: Date = .now) {
		self.id = id
		self.date = Calendar.current.startOfDay(for: date)
		self.mealType = mealType
		self.recipe = recipe
		self.recipeName = recipe?.name ?? ""
		self.createdAt = createdAt
	}
}

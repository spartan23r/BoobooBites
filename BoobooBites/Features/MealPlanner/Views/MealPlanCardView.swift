//
//  MealPlanCardView.swift
//  BoobooBites
//
//  Created by Ryan Rook on 22/03/2026.
//

import SwiftUI

struct MealPlanCardView: View {
	
	// MARK: - properties
	let mealPlan: MealPlan
	var showDate = false
	
	let deleteMealPlan: (MealPlan) -> Void
	
	// MARK: - body
	var body: some View {
		NavigationLink {
			
			MealPlannerItem(mealPlan: mealPlan)
			
		} label: {
			
			VStack(alignment: .leading, spacing: 9) {
				MealPlanDescriptionView(mealPlan: mealPlan, showDate: showDate)
				RecipeCardTagsView(recipe: mealPlan.recipe)
			}
			
		}
		.swipeActions(edge: .trailing, allowsFullSwipe: false) {
			Button(role: .destructive) {
				deleteMealPlan(mealPlan)
			}
		}
	}
}

#Preview {
	MealPlanCardView(mealPlan: MealPlan(recipe: Recipe(name: "Curry", ingredients: [])), deleteMealPlan: { _ in })
}

// MARK: - utilities
extension MealPlanCardView {}

// MARK: - views
extension MealPlanCardView {}

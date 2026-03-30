//
//  MealPlannerRecipeUsage.swift
//  BoobooBites
//
//  Created by Ryan Rook on 30/03/2026.
//

import SwiftUI
import SwiftData

struct MealPlannerRecipeUsage: View {
	
	// MARK: - properties
	@Binding var isPresented: Bool
	
	@Query private var recipes: [Recipe]
	@Query private var mealPlans: [MealPlan]
	
	// MARK: - body
    var body: some View {
		NavigationStack {
			List(recipes.sorted(by: { recipeUsage(for: $0) > recipeUsage(for: $1)  }), id: \.self) { recipe in
				LabeledContent(recipe.name, value: recipeUsage(for: recipe), format: .number)
			}
			.navigationTitle("Recipe Usage")
			.navigationSubtitle("\(mealPlans.count) meals planned")
			.toolbarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button(role: .close) {
						isPresented.toggle()
					}
				}
			}
			.presentationDetents([.medium, .large])
			.presentationDragIndicator(.visible)
		}
    }
}

#Preview {
	MealPlannerRecipeUsage(isPresented: .constant(false))
}

// MARK: - utilities
extension MealPlannerRecipeUsage {
	
	private func recipeUsage(for recipe: Recipe) -> Int {
		return mealPlans.filter({ $0.recipe.id == recipe.id }).count
	}
	
}

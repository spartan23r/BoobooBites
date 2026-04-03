//
//  MealPlanDescriptionView.swift
//  BoobooBites
//
//  Created by Ryan Rook on 24/03/2026.
//

import SwiftUI

struct MealPlanDescriptionView: View {
	
	// MARK: - properties
	let mealPlan: MealPlan
	var showDate = false
	
	// MARK: - body
	var body: some View {
		VStack(alignment: .leading) {
			
			if showDate {
				Text("\(mealPlan.date, format: .dateTime.weekday(.wide).day().month(.wide).year())")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
			
			HStack(alignment: .center, spacing: 6) {
				
				Text(mealPlan.recipe?.name ?? mealPlan.recipeName)
					.font(.subheadline)
					.bold()
					.multilineTextAlignment(.leading)
					.lineLimit(1)
				
				mealPlan.mealType.image
					.symbolVariant(.fill)
					.font(.caption2)
					.foregroundStyle(mealPlan.mealType.color.gradient)
				
			}
			
		}
	}
}

#Preview {
	MealPlanDescriptionView(mealPlan: MealPlan(recipe: Recipe(ingredients: [])))
}

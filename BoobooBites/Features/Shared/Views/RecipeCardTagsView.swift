//
//  RecipeCardTagsView.swift
//  BoobooBites
//
//  Created by Ryan Rook on 24/03/2026.
//

import SwiftUI

struct RecipeCardTagsView: View {
	
	// MARK: - properties
	let recipe: Recipe?
	
	// MARK: - body
    var body: some View {
		HStack {
			
//			Image(systemName: "fork.knife")
//				.symbolVariant(.fill)
//				.font(.caption2)
//				.foregroundStyle(Color.convertStringToColor(recipe.color).gradient)
//				.padding(6)
//				.glassEffectStyle(color: Color.convertStringToColor(recipe.color).opacity(0.2), cornerRadius: 100)
			
			if let recipe = recipe {
				
				HStack(spacing: 3) {
					Image(systemName: "clock")
						.symbolVariant(.fill)
						.font(.caption2)
					Text("\((recipe.prepTime + recipe.cookTime), format: .number)")
						.font(.caption)
						.contentTransition(.numericText())
				}
				.foregroundStyle(.recipePrepTime.gradient)
				.padding(6)
				.glassEffectStyle(color: .recipePrepTime.opacity(0.2))
				
				HStack(spacing: 3) {
					Image(systemName: "carrot")
						.symbolVariant(.fill)
						.font(.caption2)
					Text("\(recipe.ingredients.count, format: .number)")
						.font(.caption)
						.contentTransition(.numericText())
				}
				.foregroundStyle(.recipeIngredients.gradient)
				.padding(6)
				.glassEffectStyle(color: .recipeIngredients.opacity(0.2))
				
				HStack(spacing: 3) {
					Image(systemName: "person")
						.symbolVariant(.fill)
						.font(.caption2)
					Text("\(recipe.servings, format: .number)")
						.font(.caption)
						.contentTransition(.numericText())
				}
				.foregroundStyle(.recipeServings.gradient)
				.padding(6)
				.glassEffectStyle(color: .recipeServings.opacity(0.2))
				
			} else {
				
				HStack(spacing: 3) {
					Image(systemName: "questionmark.diamond")
						.symbolVariant(.fill)
						.font(.caption2)
					Text("deleted recipe")
						.font(.caption)
						.contentTransition(.numericText())
				}
				.foregroundStyle(.accent.gradient)
				.padding(6)
				.glassEffectStyle(color: .accent.opacity(0.2))
				
			}
			
		}
    }
}

#Preview {
	RecipeCardTagsView(recipe: Recipe(ingredients: []))
}

//
//  RecipeCardTagsView.swift
//  BoobooBites
//
//  Created by Ryan Rook on 24/03/2026.
//

import SwiftUI

struct RecipeCardTagsView: View {
	
	// MARK: - properties
	let recipe: Recipe
	
	// MARK: - body
    var body: some View {
		HStack {
			
//			HStack(spacing: 3) {
//				Image(systemName: "carrot")
//					.symbolVariant(.fill)
//					.font(.caption2)
//				Text("\(recipe.ingredients.count, format: .number)")
//					.font(.caption)
//			}
//			.foregroundStyle(.sonicRed.gradient)
//			.padding(6)
//			.glassEffectStyle(color: .sonicRed.opacity(0.2))
			
			HStack(spacing: 3) {
				Image(systemName: "clock")
					.symbolVariant(.fill)
					.font(.caption2)
				Text("\(recipe.prepTime, format: .number)")
					.font(.caption)
			}
			.foregroundStyle(.sonicBlue.gradient)
			.padding(6)
			.glassEffectStyle(color: .sonicBlue.opacity(0.2))
			
			HStack(spacing: 3) {
				Image(systemName: "clock")
					.symbolVariant(.fill)
					.font(.caption2)
				Text("\(recipe.cookTime, format: .number)")
					.font(.caption)
			}
			.foregroundStyle(.tailsOrange.gradient)
			.padding(6)
			.glassEffectStyle(color: .tailsOrange.opacity(0.2))
			
			HStack(spacing: 3) {
				Image(systemName: "person")
					.symbolVariant(.fill)
					.font(.caption2)
				Text("\(recipe.servings, format: .number)")
					.font(.caption)
			}
			.foregroundStyle(.sonicGreen.gradient)
			.padding(6)
			.glassEffectStyle(color: .sonicGreen.opacity(0.2))
			
		}
    }
}

#Preview {
	RecipeCardTagsView(recipe: Recipe(ingredients: []))
}

//
//  RecipeCardDescriptionView.swift
//  BoobooBites
//
//  Created by Ryan Rook on 24/03/2026.
//

import SwiftUI

struct RecipeCardDescriptionView: View {
	
	// MARK: - properties
	let recipe: Recipe
	
	// MARK: - body
    var body: some View {
		HStack(spacing: 6) {
			
			Text(recipe.name)
				.font(.subheadline)
				.bold()
				.multilineTextAlignment(.leading)
			
			if recipe.isFavorite {
				Image(systemName: "heart")
					.symbolVariant(.fill)
					.font(.caption2)
					.foregroundStyle(.sonicPink.gradient)
					.transition(.push(from: .leading))
			}
			
		}
    }
}

#Preview {
    RecipeCardDescriptionView(recipe: Recipe(ingredients: []))
}

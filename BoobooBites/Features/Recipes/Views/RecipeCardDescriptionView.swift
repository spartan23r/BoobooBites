//
//  RecipeCardDescriptionView.swift
//  BoobooBites
//
//  Created by Ryan Rook on 24/03/2026.
//

import SwiftUI

struct RecipeCardDescriptionView: View {
	
	// MARK: - properties
	@Environment(SettingsStore.self) private var settingsStore
	let recipe: Recipe
	
	// MARK: - body
    var body: some View {
		HStack(alignment: .center, spacing: 6) {
			
			HStack {
				
				if settingsStore.recipesListSortType == .color {
					
					Image(systemName: "circle")
						.symbolVariant(.fill)
						.font(.caption2)
						.foregroundStyle(Color.convertStringToColor(recipe.color).gradient)
						.transition(.asymmetric(
							insertion: .push(from: .leading)
								.combined(with: .scale(scale: 0.2)),
							removal: .push(from: .trailing)
								.combined(with: .scale(scale: 2))
						))
				}
				
				Text(recipe.name)
					.font(.subheadline)
					.bold()
					.multilineTextAlignment(.leading)
					.lineLimit(1)
				
			}
			
			if recipe.isFavorite {
				Image(systemName: "heart")
					.symbolVariant(.fill)
					.font(.caption2)
					.foregroundStyle(.sonicPink.gradient)
					.transition(.asymmetric(
						insertion: .push(from: .trailing)
							.combined(with: .scale(scale: 2)),
						removal: .push(from: .leading)
							.combined(with: .scale(scale: 0.2))
					))
			}
			
		}
    }
}

#Preview {
    RecipeCardDescriptionView(recipe: Recipe(ingredients: []))
}

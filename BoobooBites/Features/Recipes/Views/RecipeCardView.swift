//
//  RecipeCardView.swift
//  BoobooBites
//
//  Created by Ryan Rook on 21/03/2026.
//


import SwiftUI

enum RecipeNavLinkViewStyle {
	case regular, search
}

struct RecipeCardView: View {
	
	// MARK: - properties
	let recipe: Recipe
	var cardStyle: RecipeNavLinkViewStyle = .regular
	
	// MARK: - body
    var body: some View {
		switch cardStyle {
		case .regular: regularCardView()
		case .search: searchCardView()
		}
    }
}

#Preview {
	RecipeCardView(recipe: Recipe(name: "Curry", ingredients: []))
}

// MARK: - views
extension RecipeCardView {
	
	@ViewBuilder
	private func searchCardView() -> some View {
		NavigationLink {
			
			RecipesItem(recipe: recipe)
			
		} label: {
			
			Text(recipe.name)
			
		}
	}
	
	@ViewBuilder
	private func regularCardView() -> some View {
		Section {
			NavigationLink {
				
				RecipesItem(recipe: recipe)
				
			} label: {
				VStack(alignment: .leading, spacing: 9) {
					
					VStack(alignment: .leading, spacing: 6) {
						
						Text(recipe.name)
							.font(.subheadline)
							.bold()
						
						Text("\(recipe.ingredients.count, format: .number) \(recipe.ingredients.count != 1 ? "Ingredients" : "Ingredient")")
							.font(.caption)
							.foregroundStyle(.secondary)
						
					}
					
					HStack {
						
						HStack(spacing: 3) {
							Image(systemName: "clock")
								.symbolVariant(.fill)
								.font(.caption2)
							Text("\(recipe.prepTime, format: .number) min")
								.font(.caption)
						}
						.foregroundStyle(.sonicBlue.gradient)
						.padding(.vertical, 3)
						.padding(.horizontal, 6)
						.glassEffectStyle(color: .sonicBlue.opacity(0.2))
						
						HStack(spacing: 3) {
							Image(systemName: "clock")
								.symbolVariant(.fill)
								.font(.caption2)
							Text("\(recipe.cookTime, format: .number) min")
								.font(.caption)
						}
						.foregroundStyle(.tailsOrange.gradient)
						.padding(.vertical, 3)
						.padding(.horizontal, 6)
						.glassEffectStyle(color: .tailsOrange.opacity(0.2))
						
						HStack(spacing: 3) {
							Image(systemName: "person")
								.symbolVariant(.fill)
								.font(.caption2)
							Text("\(recipe.servings, format: .number)")
								.font(.caption)
						}
						.foregroundStyle(.sonicGreen.gradient)
						.padding(.vertical, 3)
						.padding(.horizontal, 6)
						.glassEffectStyle(color: .sonicGreen.opacity(0.2))
						
					}
					
				}
			}
		}
		.listSectionSpacing(.compact)
	}
}

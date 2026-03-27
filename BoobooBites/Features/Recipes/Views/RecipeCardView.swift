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
		case .regular: regularCardView
		case .search: searchCardView
		}
    }
}

#Preview {
	RecipeCardView(recipe: Recipe(name: "Curry", ingredients: []))
}

// MARK: - views
extension RecipeCardView {
	
	@ViewBuilder
	private var searchCardView: some View {
		NavigationLink {
			
			RecipesItem(recipe: recipe)
			
		} label: {
			
			Text(recipe.name)
			
		}
	}
	
	@ViewBuilder
	private var regularCardView: some View {
		Section {
			NavigationLink {
				
				RecipesItem(recipe: recipe)
				
			} label: {
				VStack(alignment: .leading, spacing: 9) {
					RecipeCardDescriptionView(recipe: recipe)
					RecipeCardTagsView(recipe: recipe)
				}
			}
			.swipeActions(allowsFullSwipe: true) {
				Button {
					withAnimation {
						recipe.isFavorite.toggle()
					}
				} label: {
					Label(
						recipe.isFavorite ? "Unfavorite" : "Favorite",
						systemImage: "heart"
					).symbolVariant(recipe.isFavorite ? .slash : .fill)
				}.tint(.sonicPink)
			}
		}
		.listSectionSpacing(.compact)
	}
}

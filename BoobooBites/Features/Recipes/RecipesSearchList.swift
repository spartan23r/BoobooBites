//
//  RecipesSearchList.swift
//  BoobooBites
//
//  Created by Ryan Rook on 21/03/2026.
//

import SwiftUI
import SwiftData

struct RecipesSearchList: View {
	
	// MARK: - properties
	@Query(sort: \Recipe.name, order: .forward) private var recipes: [Recipe]
	
	@State private var createNewRecipe = false
	
	@State private var showIngredientsList = false
	@State private var showSettings = false
	
	@Binding var searchableText: String
	
	// MARK: - body
	var body: some View {
		NavigationStack {
			Group {
				switch userIsSearching() {
				case true: searchableResultsView
				case false: allResultsView
				}
			}
			.navigationTitle("Search")
			.navigationBarTitleDisplayMode(.inline)
			.overlay(alignment: .center) {
				if recipes.isEmpty && !userIsSearching() {
					ContentUnavailableView {
						Label("No recipes available", image: "basket.badge.questionmark")
					} description: {
						Text("Added recipes will be shown here")
					}
				}
			}
		}
	}
}

#Preview {
	RecipesSearchList(searchableText: .constant(""))
}

// MARK: - utilities
extension RecipesSearchList {
	
	func userIsSearching() -> Bool {
		if searchableText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false } else { return true }
	}
	
	private func searchableRecipeResults() -> [Recipe] {
		return recipes
			.filter( {
				$0.name.localizedCaseInsensitiveContains(searchableText) ||
				$0.notes.localizedCaseInsensitiveContains(searchableText) ||
				$0.instructions.localizedCaseInsensitiveContains(searchableText) ||
				$0.ingredients.contains(where: { $0.ingredient.name.localizedCaseInsensitiveContains(searchableText) })
			})
			.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
	}
}

// MARK: - views
extension RecipesSearchList {
	
	@ViewBuilder
	private var allResultsView: some View {
		List(recipes.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }), id: \.self) { recipe in
			RecipeCardView(recipe: recipe, cardStyle: .search)
		}
		.listStyle(.plain)
	}
	
	@ViewBuilder
	private var searchableResultsView: some View {
		if searchableRecipeResults().isEmpty {
			ContentUnavailableView("No recipes found", systemImage: "magnifyingglass", description: Text("Search on name, notes, instructions, and ingredients"))
		} else {
			List(searchableRecipeResults(), id: \.self) { recipe in
				RecipeCardView(recipe: recipe, cardStyle: .search)
			}
			.listStyle(.plain)
		}
	}
	
}

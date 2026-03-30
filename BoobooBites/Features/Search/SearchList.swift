//
//  RecipesSearchList.swift
//  BoobooBites
//
//  Created by Ryan Rook on 21/03/2026.
//

import SwiftUI
import SwiftData

enum SearchListType: String, CaseIterable {
	case recipes, ingredients
}

struct SearchList: View {
	
	// MARK: - properties
	@Binding var selectedSearchListType: SearchListType
	@Binding var searchableText: String
	
	@Query(sort: \Recipe.name, order: .forward) private var recipes: [Recipe]
	@Query(sort: \Ingredient.name, order: .forward) private var ingredients: [Ingredient]
	
	// MARK: - body
	var body: some View {
		NavigationStack {
			Group {
				switch userIsSearching {
				case true: searchableResultsView
				case false: allResultsView
				}
			}
			.navigationTitle("Search")
			.navigationBarTitleDisplayMode(.inline)
			.overlay(alignment: .center) {
				switch selectedSearchListType {
				case .recipes:
					
					if recipes.isEmpty && !userIsSearching {
						ContentUnavailableView {
							Label("No recipes yet", image: "basket.badge.questionmark")
						} description: {
							Text("Add your first recipe to search and organize your meals")
						}
					}
					
				case .ingredients:
					
					if ingredients.isEmpty && !userIsSearching {
						ContentUnavailableView {
							Label("No ingredients yet", image: "carrot.badge.questionmark")
						} description: {
							Text("Add ingredients to start building recipes")
						}
					}
					
				}
			}
			.toolbar {
				ToolbarItem(placement: .principal) {
					Picker("Search", selection: $selectedSearchListType.animation()) {
						ForEach(SearchListType.allCases, id: \.self) { type in
							Text(type.rawValue.capitalized).tag(type)
						}
					}
					.pickerStyle(.segmented)
				}
			}
		}
	}
}

#Preview {
	SearchList(selectedSearchListType: .constant(.recipes), searchableText: .constant(""))
}

// MARK: - utilities
extension SearchList {
	
	private var userIsSearching: Bool {
		if searchableText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false } else { return true }
	}
	
	private var searchableRecipeResults: [Recipe] {
		return recipes
			.filter( {
				$0.name.localizedCaseInsensitiveContains(searchableText) ||
				$0.notes.localizedCaseInsensitiveContains(searchableText) ||
				$0.instructions.localizedCaseInsensitiveContains(searchableText) ||
				$0.ingredients.contains(where: { $0.name.localizedCaseInsensitiveContains(searchableText) })
			})
			.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
	}
	
	private var searchableIngredientsResults: [Ingredient] {
		return ingredients
			.filter( {
				$0.name.localizedCaseInsensitiveContains(searchableText) ||
				$0.notes.localizedCaseInsensitiveContains(searchableText)
			})
			.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
	}
}

// MARK: - views
extension SearchList {
	
	@ViewBuilder
	private var allResultsView: some View {
		switch selectedSearchListType {
		case .recipes:
			
			List(recipes.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }), id: \.self) { recipe in
				RecipeCardView(recipe: recipe, cardStyle: .search)
			}
			.listStyle(.plain)
			
		case .ingredients:
			
			List(ingredients.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }), id: \.self) { ingredient in
				IngredientCardView(ingredient: ingredient, cardStyle: .search)
			}
			.listStyle(.plain)
			
		}
	}
	
	@ViewBuilder
	private var searchableResultsView: some View {
		switch selectedSearchListType {
		case .recipes:
			
			if searchableRecipeResults.isEmpty {
				
				ContentUnavailableView("No results found", systemImage: "magnifyingglass", description: Text("Search on recipe name, notes, instructions, and ingredients"))
				
			} else {
				
				List(searchableRecipeResults, id: \.self) { recipe in
					RecipeCardView(recipe: recipe, cardStyle: .search)
				}
				.listStyle(.plain)
				
			}
			
		case .ingredients:
			
			if searchableIngredientsResults.isEmpty {
				
				ContentUnavailableView("No results found", systemImage: "magnifyingglass", description: Text("Search on ingredient name, and notes"))
				
			} else {
				
				List(searchableIngredientsResults, id: \.self) { ingredient in
					IngredientCardView(ingredient: ingredient, cardStyle: .search)
				}
				.listStyle(.plain)
				
			}
			
		}
	}
}

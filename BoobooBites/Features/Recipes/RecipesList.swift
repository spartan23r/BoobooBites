//
//  RecipesList.swift
//  BoobooBites
//
//  Created by Ryan Rook on 20/03/2026.
//

import SwiftUI
import SwiftData

struct RecipesList: View {
	
	// MARK: - properties
	@Environment(SettingsStore.self) private var settingsStore
	
	@Query private var recipes: [Recipe]
	
	@State private var newRecipe = false
	
	@State private var showIngredientsList = false
	
	@State private var showSettings = false
	
	@State private var showPaywall = false
	
	// for importing mock data
	@Environment(\.modelContext) private var modelContext
	
	// MARK: - body
	var body: some View {
		NavigationStack {
			List(sortedRecipes(), id: \.self) { recipe in
				RecipeCardView(recipe: recipe)
			}
			.navigationTitle("Recipes")
			.navigationSubtitle("\(recipes.count) stored")
			.sheet(isPresented: $newRecipe) {
				RecipesAdd(isPresented: $newRecipe)
			}
			.sheet(isPresented: $showIngredientsList) {
				IngredientsList(isPresented: $showIngredientsList)
			}
			.sheet(isPresented: $showSettings) {
				SettingsList(isPresented: $showSettings)
			}
			.toolbar {
				
				if recipes.count > 0 {
					
					ToolbarItem(placement: .primaryAction) {
						
						Menu {
							
							ForEach(RecipesListSortType.allCases, id: \.self) { type in
								Button {
									settingsStore.setListSorting(to: type)
								} label: {
									switch settingsStore.recipesListSortType == type {
									case true: Label(type.description.capitalized, systemImage: "checkmark")
									case false: Text(type.description.capitalized)
									}
								}
								.tag(type)
								.tint(.primary)
							}
							
							Divider()
							
							Menu {
								
								ForEach(RecipesListFilterType.allCases, id: \.self) { type in
									Button {
										settingsStore.setListFilter(to: type)
									} label: {
										switch settingsStore.recipesListFilterType == type {
										case true: Label(type.description.capitalized, systemImage: "checkmark")
										case false: Label(type.description.capitalized, systemImage: type.image)
										}
									}
									.tag(type)
									.tint(.primary)
								}
								
							} label: {
								Text("Filter")
								if settingsStore.recipesListFilterType != .all {
									Text(settingsStore.recipesListFilterType.description)
								}
							}
							.menuActionDismissBehavior(.disabled)
							
							if settingsStore.recipesListFilterType != .all {
								Button {
									settingsStore.resetListFilter()
								} label: {
									Label("Remove Filter", systemImage: "minus")
										.symbolVariant(.circle)
								}
								.tint(.primary)
							}
							
							
						} label: {
							Image(systemName: settingsStore.recipesListFilterType == .all ? "line.3.horizontal.decrease" : "heart")
								.symbolVariant(settingsStore.recipesListFilterType == .all ? .none : .fill)
								.symbolEffect(.bounce.down, value: settingsStore.recipesListFilterType)
						}
						.tint(settingsStore.recipesListFilterType == .all ? .primary : .sonicPink)
						
					}
					
					ToolbarSpacer(.fixed, placement: .primaryAction)
					
				}
				
				ToolbarItemGroup(placement: .primaryAction) {
					
					Menu {
						
						Button {
							showSettings.toggle()
						} label: {
							Label("Settings", systemImage: "gear")
						}
						
					} label: {
						Image(systemName: "ellipsis")
					}
					
					Button {
						showIngredientsList.toggle()
					} label: {
						Label("Ingredients", systemImage: "carrot")
					}
					
					Button {
						createNewRecipe()
					} label: {
						Image(systemName: "plus")
					}
					
				}
				
			}
			.overlay(alignment: .center) {
				
				if recipes.isEmpty {
					
					ContentUnavailableView {
						Label("Create your first recipe", image: "fork.knife.badge.questionmark")
					} description: {
						Text("Start building your personal cookbook")
					} actions: {
						
						Button("Create recipe") {
							createNewRecipe()
						}
						.buttonStyle(.glassProminent)
						
						// DEV ONLY
						addMockDataButton
						
					}
					
				} else {
					
					if sortedRecipes().count == 0 {
						
						ContentUnavailableView {
							Label("No favorite recipes yet", systemImage: "heart")
								.symbolVariant(.fill)
						} description: {
							Text("Mark recipes as favorites to see them here")
						} actions: {
							Button("Show all recipes") {
								withAnimation {
									settingsStore.recipesListFilterType = .all
								}
							}
							.buttonStyle(.glassProminent)
						}
						
					}
					
				}
				
				
			}
			.showPaywall(showPaywallMessage: $showPaywall, paywallMessage: .recipes)
		}
	}
}

#Preview {
    RecipesList()
}

// MARK: - utilities
extension RecipesList {
	
	private func reachFreeRecipesLimit() -> Bool {
		if recipes.count >= 7 && !ProAccessManager.premiumPurchased { return true } else { return false }
	}
	
	private func createNewRecipe() {
		switch reachFreeRecipesLimit() {
		case true: showPaywall.toggle()
		case false: newRecipe.toggle()
		}
	}
	
	private func sortedRecipes() -> [Recipe] {
		
		var recipesList = recipes
		
		if settingsStore.recipesListFilterType == .favorites {
			recipesList = recipesList.filter({ $0.isFavorite })
		}
		
		recipesList = switch settingsStore.recipesListSortType {
		case .name: recipesList.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
		case .color: recipesList.sorted(by: { $0.color < $1.color })
		case .preparationTime: recipesList.sorted(by: { ($0.prepTime + $0.cookTime) < ($1.prepTime + $1.cookTime) })
		case .ingredientsCount: recipesList.sorted(by: { $0.ingredients.count < $1.ingredients.count })
		case .servingsCount: recipesList.sorted(by: { $0.servings < $1.servings })
		case .lastUpdated: recipesList.sorted(by: { $0.lastUpdated > $1.lastUpdated })
		case .createdAt: recipesList.sorted(by: { $0.createdAt < $1.createdAt })
		}
		
		return recipesList
	}
}

// MARK: - mock utilities
extension RecipesList {
	
	@ViewBuilder
	fileprivate var addMockDataButton: some View {
#if targetEnvironment(simulator)
						Button("Import mock recipes") {
							importMockRecipes()
						}
						.buttonStyle(.glassProminent)
#endif
	}
	
	fileprivate func importMockRecipes() {
		
		createMockRecipes().forEach { recipe in
			modelContext.insert(recipe)
		}

		do {
			try? modelContext.save()
		}
		
	}
	
	fileprivate func createMockRecipes() -> [Recipe] {
		[
			Recipe(
				name: "Curry Leblanc",
				notes: "A rich and comforting Japanese-style curry with tender chicken, soft vegetables, and a thick savory sauce. Perfect for a cozy dinner.",
				color: "appleCyan",
				instructions:
					"""
					1. Prepare ingredients
					Peel and chop the carrots and potatoes into bite-sized pieces.
					Finely chop the onion and garlic.
					Cut the chicken into small chunks.
					
					2. Cook the chicken
					Heat a large pan over medium heat with a bit of oil.
					Add the chicken and cook until lightly browned on all sides. Remove and set aside.
					
					3. Sauté aromatics
					In the same pan, add the onion and cook until soft and translucent.
					Add garlic and cook for another 1 minute.
					
					4. Add vegetables
					Add carrots and potatoes to the pan. Stir for a few minutes.
					
					5. Simmer
					Return the chicken to the pan and add water until everything is just covered.
					Bring to a boil, then reduce heat and simmer for 15–20 minutes until vegetables are tender.
					
					6. Add curry base
					Stir in curry sauce (or curry cubes if using).
					Let it simmer until the sauce thickens.
					
					7. Cook rice
					Meanwhile, cook rice according to package instructions.
					
					8. Serve
					Serve the curry over rice while hot.
					""",
				prepTime: 30,
				cookTime: 25,
				servings: 4,
				ingredients: [
					RecipeIngredient(name: "Carrots", color: "appleOrange", unit: .grams, amount: 60, sourceIngredientID: nil),
					RecipeIngredient(name: "Chicken", color: "appleRed", unit: .grams, amount: 120, sourceIngredientID: nil),
					RecipeIngredient(name: "Onion", color: "applePurple", unit: .pieces, amount: 1, sourceIngredientID: nil),
					RecipeIngredient(name: "Garlic", color: "applePurple", unit: .pieces, amount: 1, sourceIngredientID: nil),
					RecipeIngredient(name: "Potatoes", color: "appleYellow", unit: .grams, amount: 80, sourceIngredientID: nil),
					RecipeIngredient(name: "Rice", color: "appleGray", unit: .cups, amount: 2, sourceIngredientID: nil),
					RecipeIngredient(name: "Water", color: "appleBlue", unit: .milliliters, amount: 550, sourceIngredientID: nil)
				]
			),
			Recipe(
				name: "Creamy Chicken Pasta",
				notes: "",
				color: "appleCoral",
				instructions: "",
				prepTime: 20,
				cookTime: 20,
				servings: 4,
				ingredients: [
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil)
				]
			),
			Recipe(
				name: "Avocado Toast",
				notes: "",
				color: "appleGreen",
				instructions: "",
				prepTime: 5,
				cookTime: 0,
				servings: 1,
				ingredients: [
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil)
				]
			),
			Recipe(
				name: "Beef Tacos",
				notes: "",
				color: "appleOrange",
				instructions: "",
				prepTime: 15,
				cookTime: 15,
				servings: 3,
				ingredients: [
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil)
				]
			),
			Recipe(
				name: "Vegetable Stir Fry",
				notes: "A quick and colorful stir fry packed with fresh vegetables and tossed in a savory soy-based sauce. Light, healthy, and ready in minutes.",
				color: "appleRed",
				instructions:
					"""
					1. Prepare ingredients
					Chop broccoli into small florets.
					Slice bell pepper, carrots, and mushrooms.
					Trim snap peas.
					Finely chop garlic and onion.
					
					2. Cook noodles
					Cook noodles according to package instructions. Drain and set aside.
					
					3. Heat the pan
					Heat a wok or large pan over high heat. Add a bit of oil.
					
					4. Cook aromatics
					Add onion and garlic. Stir fry for about 1 minute until fragrant.
					
					5. Add vegetables
					Add broccoli, carrots, and bell pepper first.
					Stir fry for 2–3 minutes.
					Then add snap peas and mushrooms and cook for another 2–3 minutes.
					
					6. Add sauce
					Pour in soy sauce and a drizzle of sesame oil.
					Toss everything to coat evenly.
					
					7. Combine noodles
					Add the cooked noodles to the pan.
					Toss everything together until well mixed and heated through.
					
					8. Serve
					Serve immediately while hot.
					""",
				prepTime: 15,
				cookTime: 10,
				servings: 2,
				ingredients: [
					RecipeIngredient(name: "Broccoli", color: "appleGreen", unit: .grams, amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "Bell Pepper", color: "appleRed", unit: .pieces, amount: 1, sourceIngredientID: nil),
					RecipeIngredient(name: "Carrots", color: "appleOrange", unit: .grams, amount: 70, sourceIngredientID: nil),
					RecipeIngredient(name: "Snap Peas", color: "appleGreen", unit: .grams, amount: 80, sourceIngredientID: nil),
					RecipeIngredient(name: "Mushrooms", color: "appleBrown", unit: .grams, amount: 60, sourceIngredientID: nil),
					RecipeIngredient(name: "Onion", color: "applePurple", unit: .pieces, amount: 1, sourceIngredientID: nil),
					RecipeIngredient(name: "Garlic", color: "applePurple", unit: .pieces, amount: 2, sourceIngredientID: nil),
					RecipeIngredient(name: "Soy Sauce", color: "appleBrown", unit: .tablespoons, amount: 2, sourceIngredientID: nil),
					RecipeIngredient(name: "Noodles", color: "appleYellow", unit: .grams, amount: 120, sourceIngredientID: nil),
					RecipeIngredient(name: "Sesame Oil", color: "appleOrange", unit: .teaspoons, amount: 1, sourceIngredientID: nil)
				]
			),
			Recipe(
				name: "Pancakes",
				notes: "",
				color: "appleBrown",
				instructions: "",
				prepTime: 10,
				cookTime: 10,
				servings: 2,
				ingredients: [
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
				]
			),
			Recipe(
				name: "Grilled Salmon Bowl",
				notes: "",
				color: "applePink",
				instructions: "",
				prepTime: 15,
				cookTime: 12,
				servings: 2,
				ingredients: [
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil),
					RecipeIngredient(name: "", color: "appleRed", amount: 100, sourceIngredientID: nil)
				]
			),
		]
	}
}

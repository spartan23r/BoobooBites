//
//  IngredientsList.swift
//  BoobooBites
//
//  Created by Ryan Rook on 20/03/2026.
//

import SwiftUI
import SwiftData

struct IngredientsList: View {
	
	// MARK: - properties
	@Binding var isPresented: Bool
	
	@Environment(SettingsStore.self) private var settingsStore
	
	@Environment(\.modelContext) private var modelContext
	
	@Query(sort: \Ingredient.name, order: .forward) private var ingredients: [Ingredient]
	
	@State private var newIngredient = false
	
	@State private var showPaywall = false
	
	// MARK: - body
	var body: some View {
		NavigationStack {
			List(sortedIngredients(), id: \.self) { ingredient in
				NavigationLink {
					
					IngredientsItem(ingredient: ingredient) { _ in }
					
				} label: {
					HStack {
						Image(systemName: "circle")
							.symbolVariant(.fill)
							.symbolEffect(.wiggle, value: Color.convertStringToColor(ingredient.color))
							.font(.caption)
							.foregroundStyle(Color.convertStringToColor(ingredient.color).gradient)
						Text(ingredient.name)
							.contentTransition(.numericText())
					}
				}
			}
			.navigationTitle("Ingredients")
			.navigationSubtitle("\(ingredients.count) stored")
			.sheet(isPresented: $newIngredient) {
				IngredientsAdd(isPresented: $newIngredient) { _ in }
			}
			.toolbar {
				
				ToolbarItem(placement: .topBarLeading) {
					Button(role: .close) {
						isPresented.toggle()
					}
				}
				
				if ingredients.count > 0 {
					
					ToolbarItem(placement: .primaryAction) {
						
						Menu {
							
							ForEach(IngredientsListSortType.allCases, id: \.self) { type in
								Button {
									withAnimation {
										settingsStore.ingredientsListSortType = type
									}
								} label: {
									switch settingsStore.ingredientsListSortType == type {
									case true: Label(type.description.capitalized, systemImage: "checkmark")
									case false: Text(type.description.capitalized)
									}
								}
								.tag(type)
								.tint(.primary)
							}
							
						} label: {
							Image(systemName: "line.3.horizontal.decrease")
						}
						
					}
					
					ToolbarSpacer(.fixed, placement: .primaryAction)
					
				}
				
				
				ToolbarItem(placement: .primaryAction) {
					Button {
						createNewIngredient()
					} label: {
						Image(systemName: "plus")
					}
				}
				
			}
			.overlay(alignment: .center) {
				if ingredients.isEmpty {
					ContentUnavailableView {
						Label("No ingredients available", image: "carrot.badge.questionmark")
					} description: {
						Text("Added ingredients will be shown here")
					} actions: {
						Button("Add new ingredient") {
							newIngredient.toggle()
						}
						.buttonStyle(.glassProminent)
					}
				}
			}
			.showPaywall(showPaywallMessage: $showPaywall, paywallMessage: .ingredients)
			.presentationDetents([.large])
			.interactiveDismissDisabled()
		}
	}
}

#Preview {
	IngredientsList(isPresented: .constant(false))
}

// MARK: - utilities
extension IngredientsList {
	
	private func reachFreeIngredientsLimit() -> Bool {
		if ingredients.count >= 12 && !ProAccessManager.premiumPurchased { return true } else { return false }
	}
	
	private func createNewIngredient() {
		switch reachFreeIngredientsLimit() {
		case true: showPaywall.toggle()
		case false: newIngredient.toggle()
		}
	}
	
	private func sortedIngredients() -> [Ingredient] {
		
		var ingredientsList = ingredients
		
		ingredientsList = switch settingsStore.ingredientsListSortType {
		case .name: ingredientsList.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
		case .color: ingredientsList.sorted(by: { $0.color < $1.color })
//		case .defaultUnit: ingredientsList.sorted(by: { $0.defaultUnit.rawValue < $1.defaultUnit.rawValue })
		}
		
		return ingredientsList
	}
	
}

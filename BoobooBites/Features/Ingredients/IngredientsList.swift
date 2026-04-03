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
	
	@Query private var ingredients: [Ingredient]
	
	@State private var newIngredient = false
	
	@State private var showPaywall = false
	
	@State private var deleteConfirmationDialog = false
	
	@State private var hapticWarning = false
	@State private var hapticDeleted = false
	
	@Query private var recipeIngredients: [RecipeIngredient]
	
	// MARK: - body
	var body: some View {
		NavigationStack {
			List(sortedIngredients(), id: \.self) { ingredient in
				IngredientCardView(ingredient: ingredient)
			}
			.navigationTitle("Ingredients")
			.navigationSubtitle("\(ingredients.count) stored")
			.toolbarTitleDisplayMode(.large)
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
				
				ToolbarItemGroup(placement: .primaryAction) {
					
					Menu {
						Button("Delete All", systemImage: "trash", role: .destructive) {
							deleteConfirmationDialog.toggle()
							settingsStore.triggerHaptic(&hapticWarning)
						}
						.disabled(ingredients.isEmpty)
					} label: {
						Image(systemName: "ellipsis")
					}
					.confirmationDialog("Delete All Ingredients?", isPresented: $deleteConfirmationDialog, titleVisibility: .hidden) {
						Button("Delete All Ingredients", role: .destructive) {
							deleteAllIngredients()
						}
					} message: {
						Text("All ingredients will be removed from your list, but existing recipes will stay unchanged. This action can’t be undone.")
					}
					
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
						Label("No ingredients yet", image: "carrot.badge.questionmark")
					} description: {
						Text("Add ingredients to reuse in your recipes")
					} actions: {
						Button("Add ingredient") {
							newIngredient.toggle()
						}
						.buttonStyle(.glassProminent)
					}
				}
			}
			.showPaywall(showPaywallMessage: $showPaywall, paywallMessage: .ingredients)
			.presentationDetents([.large])
			.presentationDragIndicator(.visible)
//			.interactiveDismissDisabled()
			.sensoryFeedback(.warning, trigger: hapticWarning)
			.sensoryFeedback(.success, trigger: hapticDeleted)
		}
	}
}

#Preview {
	IngredientsList(isPresented: .constant(false))
}

// MARK: - utilities
extension IngredientsList {
	
	private func reachFreeIngredientsLimit() -> Bool {
		if ingredients.count >= 25 && !ProAccessManager.premiumPurchased { return true } else { return false }
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
	
	private func deleteAllIngredients() {
		
		AnalyticsUtils.logButtonTap(screen: .ingredientList, button: .deleteAll)
		settingsStore.triggerHaptic(&hapticDeleted)
		
		DispatchQueue.main.async {
			
			ingredients.forEach { ingredient in
				modelContext.delete(ingredient)
			}
			
			clearRecipeIngredientsSourceIngredientID()
			
			do {
				try modelContext.save()
			} catch {
				print("Error removing ingredients: \(error.localizedDescription)")
			}
			
		}
	}
	
	private func clearRecipeIngredientsSourceIngredientID() {
		recipeIngredients.forEach { recipeIngredient in
			recipeIngredient.sourceIngredientID = nil
		}
	}
	
}

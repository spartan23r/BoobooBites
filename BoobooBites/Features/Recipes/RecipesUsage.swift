//
//  RecipesUsage.swift
//  BoobooBites
//
//  Created by Ryan Rook on 30/03/2026.
//

import SwiftUI
import SwiftData
import Charts

struct RecipesUsage: View {
	
	// MARK: - properties
	@Binding var isPresented: Bool
	
	@Query private var recipes: [Recipe]
	@Query private var mealPlans: [MealPlan]
	
	// MARK: - body
    var body: some View {
		NavigationStack {
			List {
				
				if !topRecipeUsageItems.isEmpty {
					Section {
						Chart(topRecipeUsageItems) { item in
							SectorMark(
								angle: .value("Usage", item.usageCount),
								innerRadius: .ratio(0.6)
							)
							.foregroundStyle(by: .value("Recipe", item.name))
						}
						.chartForegroundStyleScale(
							domain: topRecipeUsageItems.map(\.name),
							range: topRecipeUsageItems.map { Color.convertStringToColor($0.color) }
						)
						.chartLegend(.hidden)
						.frame(height: 120)
					} header: {
						Text("Top Recipes")
					}
				}
				
				if !recipeUsageItems.filter({ $0.usageCount > 0 }).isEmpty {
					Section {
						ForEach(recipeUsageItems.filter { $0.usageCount > 0 }, id: \.self) { item in
							LabeledContent {
								Text(item.usageCount, format: .number)
							} label: {
								HStack {
									Image(systemName: "circle.fill")
										.font(.caption2)
										.foregroundStyle(Color.convertStringToColor(item.color))
									
									Text(item.name)
								}
							}
						}
					} header: {
						Text("Used Recipes")
					}
				}
				
				if !recipeUsageItems.filter({ $0.usageCount == 0 }).isEmpty {
					Section {
						ForEach(recipeUsageItems.filter { $0.usageCount == 0 }, id: \.self) { item in
							LabeledContent {
								Text(item.usageCount, format: .number)
							} label: {
								HStack {
									Image(systemName: "circle.fill")
										.font(.caption2)
										.foregroundStyle(Color.convertStringToColor(item.color))
									
									Text(item.name)
								}
							}
						}
					} header: {
						Text("Unused Recipes")
					}
				}
				
				
			}
			.navigationTitle("Most Used Recipes")
			.navigationSubtitle(recipes.count > 0 ? "Used in \(mealPlans.count) meals" : "No data yet")
			.toolbarTitleDisplayMode(.large)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button(role: .close) {
						isPresented.toggle()
					}
				}
			}
			.overlay {
				if noRecipesAvailable {
					ContentUnavailableView {
						Label("No recipes yet", image: "basket.badge.questionmark")
					} description: {
						Text("Create a recipe to start planning meals")
					}
				}
			}
			.presentationDetents([.medium, .large])
			.presentationDragIndicator(.visible)
		}
    }
}

#Preview {
	RecipesUsage(isPresented: .constant(false))
}

// MARK: - utilities
extension RecipesUsage {
	
	private var noRecipesAvailable: Bool {
		recipes.isEmpty
	}
	
	private var recipeUsageByID: [UUID: Int] {
		Dictionary(grouping: mealPlans.compactMap { $0.recipe?.id }, by: { $0 })
			.mapValues(\.count)
	}
	
	private var recipeUsageItems: [RecipeUsageItem] {
		recipes
			.map { recipe in
				RecipeUsageItem(
					id: recipe.id,
					name: recipe.name,
					color: recipe.color,
					usageCount: recipeUsageByID[recipe.id, default: 0]
				)
			}
			.sorted { $0.usageCount > $1.usageCount }
	}
	
	private var topRecipeUsageItems: [RecipeUsageItem] {
		Array(
			recipeUsageItems
				.filter { $0.usageCount > 0 }
				.prefix(5)
		)
	}
}

struct RecipeUsageItem: Identifiable, Hashable {
	let id: UUID
	let name: String
	let color: String
	let usageCount: Int
}

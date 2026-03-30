//
//  MealPlannerAdd.swift
//  BoobooBites
//
//  Created by Ryan Rook on 21/03/2026.
//

import SwiftUI
import SwiftData

struct MealPlannerAdd: View {
	
	// MARK: - properties
	@Binding var isPresented: Bool
	
	@Environment(SettingsStore.self) private var settingsStore
	
	@Environment(\.modelContext) private var modelContext
	
	@Query(sort: \Recipe.name, order: .forward) private var recipes: [Recipe]
	
	@Binding var selectedDate: Date
	
	@State private var selectedRecipe: Recipe? = nil
	
	@State private var hapticSaved = false
	
	let completion: () -> Void
	
	// MARK: - body
    var body: some View {
		NavigationStack {
			Form {
				
				Section {
					datePicker
					mealPlanTypePicker
				}
				
				if let recipe = selectedRecipe {
					Section {
						recipePicker(recipe)
						recipeDetails(recipe)
					} footer: {
						RecipeCardTagsView(recipe: recipe)
							.frame(maxWidth: .infinity, alignment: .trailing)
					}
				} else {
					ContentUnavailableView {
						Label("No recipes yet", image: "basket.badge.questionmark")
					} description: {
						Text("Create a recipe to start planning meals")
					}
				}
				
			}
			.navigationTitle("New Meal Plan")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				
				ToolbarItem(placement: .topBarLeading) {
					Button(role: .close) {
						isPresented.toggle()
					}
				}
				
				ToolbarItem(placement: .primaryAction) {
					Button(role: .confirm) {
						saveNewMealPlan()
					}
					.disabled(disabledToSave())
				}
				
			}
			.presentationDetents([.large])
			.interactiveDismissDisabled()
			.onAppear {
				selectedRecipe = recipes.first
			}
			.onDisappear {
				completion()
			}
			.sensoryFeedback(.success, trigger: hapticSaved)
		}
    }
}

#Preview {
	MealPlannerAdd(isPresented: .constant(false), selectedDate: .constant(Date()), completion: {})
}

// MARK: - utilities
extension MealPlannerAdd {
	
	private func disabledToSave() -> Bool {
		if selectedRecipe == nil {
			return true
		} else {
			return false
		}
	}
	
	func saveNewMealPlan() {
		if let recipe = selectedRecipe {
			let mealPlan = MealPlan(
				date: selectedDate,
				mealType: settingsStore.defaultMealPlanType,
				recipe: recipe
			)
			
			modelContext.insert(mealPlan)

			do {
				try? modelContext.save()
			}
			
			isPresented.toggle()
			settingsStore.triggerHaptic(&hapticSaved)
			AnalyticsUtils.logButtonTap(screen: .mealPlanAdd, button: .save)
		}
	}
	
}

// MARK: - views
extension MealPlannerAdd {
	
	@ViewBuilder
	private var datePicker: some View {
		DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
	}
	
	@ViewBuilder
	private var mealPlanTypePicker: some View {
		Picker(selection: Binding(
			get: { settingsStore.defaultMealPlanType },
			set: { settingsStore.defaultMealPlanType = $0 }
		), content: {
			ForEach(MealType.allCases, id: \.self) { type in
				Text(type.rawValue.capitalized).tag(type)
			}
		}, label: {
			settingsStore.defaultMealPlanType.image
				.foregroundStyle(.white)
				.symbolEffect(.rotate, value: settingsStore.defaultMealPlanType)
				.listRoundedIconStyle(bgc: settingsStore.defaultMealPlanType.color, filledIconStyle: true)
				.font(.subheadline)
		})
		.tint(.accent)
		.animation(.smooth, value: settingsStore.defaultMealPlanType)
	}
	
	@ViewBuilder
	private func recipePicker(_ recipe: Recipe) -> some View {
		Picker(selection: $selectedRecipe.animation()) {
			ForEach(recipes, id: \.self) { recipe in
				Text(recipe.name)
					.multilineTextAlignment(.trailing)
					.tag(recipe)
			}
		} label: {
			Image(systemName: "fork.knife")
				.symbolEffect(.bounce, value: selectedRecipe)
		}
		.foregroundStyle(.white)
		.tint(.white)
		.bold()
		.labelsHidden()
		.frame(maxWidth: .infinity, alignment: .trailing)
		.listRowBackground(Color.convertStringToColor(recipe.color))
		.listRowSeparator(.hidden, edges: .bottom)
		
	}
	
	@ViewBuilder
	private func recipeDetails(_ recipe: Recipe) -> some View {
		
		DisclosureGroup {
				if recipe.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
					
					Text("No notes available")
						.foregroundStyle(.secondary)
					
				} else {
					
					Text(recipe.notes)
					
				}
		} label: {
			Text("Notes")
		}
		
		DisclosureGroup {
			
			LabeledContent {
				HStack {
					Text(recipe.prepTime, format: .number)
						.contentTransition(.numericText())
					Text(recipe.prepTime != 1 ? "Minutes" : "Minute")
				}
			} label: {
				HStack {
					Image(systemName: "circle")
						.symbolVariant(.fill)
						.font(.caption)
						.foregroundStyle(.recipePrepTime.gradient)
					Text("Prep time")
				}
			}
			
			LabeledContent {
				HStack {
					Text(recipe.cookTime, format: .number)
						.contentTransition(.numericText())
					Text(recipe.cookTime != 1 ? "Minutes" : "Minute")
				}
			} label: {
				HStack {
					Image(systemName: "circle")
						.symbolVariant(.fill)
						.font(.caption)
						.foregroundStyle(.recipeCookTime.gradient)
					Text("Cook time")
				}
			}
			
			LabeledContent {
				HStack {
					Text(recipe.servings, format: .number)
						.contentTransition(.numericText())
					Text(recipe.servings != 1 ? "Persons" : "Person")
				}
			} label: {
				HStack {
					Image(systemName: "circle")
						.symbolVariant(.fill)
						.font(.caption)
						.foregroundStyle(.recipeServings.gradient)
					Text("Servings")
				}
			}
			
		} label: {
			Text("Details")
		}
		
		DisclosureGroup {
			
			if recipe.ingredients.isEmpty {
				
				Text("No ingredients")
					.foregroundStyle(.secondary)
				
			} else {
				
				ForEach(recipe.ingredients.sorted(by: { $0.name < $1.name})) { recipeIngredient in
					LabeledContent {
						HStack {
							Text(recipeIngredient.amount, format: .number)
							Text(recipeIngredient.unit.rawValue)
						}
					} label: {
						HStack {
							Image(systemName: "circle")
								.symbolVariant(.fill)
								.font(.caption)
								.foregroundStyle(Color.convertStringToColor(recipeIngredient.color).gradient)
							Text(recipeIngredient.name)
						}
					}
				}
				
			}
			
		} label: {
			Text("Ingredients")
		}
		
		DisclosureGroup {
			
			Group {
				if recipe.instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
					
					Text("No instructions available")
						.foregroundStyle(.secondary)
					
				} else {
					
					Text(recipe.instructions)
					
				}
			}
			
		} label: {
			Text("Instructions")
		}
		
	}
	
}

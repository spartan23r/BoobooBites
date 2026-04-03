//
//  MealPlannerItem.swift
//  BoobooBites
//
//  Created by Ryan Rook on 22/03/2026.
//

import SwiftUI
import SwiftData

struct MealPlannerItem: View {
	
	// MARK: - properties
	@Environment(SettingsStore.self) private var settingsStore
	
	@Environment(\.modelContext) private var modelContext
	
	@Environment(\.dismiss) var dismiss
	
	@State var mealPlan: MealPlan
	
	@State private var editDate: Bool = false
	@State private var editDateValue: Date = Date().startOfDay
	@State private var editMealTypeValue: MealType = .dinner
	
	@State private var editRecipe: Bool = false
	
	@State private var deleteConfirmationDialog = false
	
	@State private var hapticWarning = false
	@State private var hapticDeleted = false
	@State private var hapticSaved = false
	
	@Query(sort: \Recipe.name, order: .forward) private var recipes: [Recipe]
	
	// MARK: - body
	var body: some View {
		NavigationStack {
			Form {
				
				Section {
					mealPlanDateView
				}
				
				Section {
					recipeNameView
					recipeDetailsView
				} footer: {
					RecipeCardTagsView(recipe: mealPlan.recipe)
						.frame(maxWidth: .infinity, alignment: .trailing)
				}
				
			}
			.navigationTitle("Meal Plan")
			.toolbarTitleDisplayMode(.large)
			.sheet(isPresented: $editDate) {
				NavigationStack {
					Form {
						
						DatePicker("Date", selection: $editDateValue, displayedComponents: .date)
						
						
						Picker(selection: $editMealTypeValue, content: {
							ForEach(MealType.allCases, id: \.self) { type in
								Text(type.rawValue.capitalized).tag(type)
							}
						}, label: {
							editMealTypeValue.image
								.foregroundStyle(.white)
								.symbolEffect(.rotate, value: editMealTypeValue)
								.listRoundedIconStyle(bgc: editMealTypeValue.color, filledIconStyle: true)
								.font(.subheadline)
						})
						.tint(.accent)
						.animation(.smooth, value: editMealTypeValue)
						
					}
					.navigationTitle("Date")
					.navigationBarTitleDisplayMode(.inline)
					.toolbar {
						ToolbarItem(placement: .topBarLeading) {
							Button(role: .close) {
								editDate.toggle()
							}
						}
						ToolbarItem(placement: .primaryAction) {
							Button(role: .confirm) {
								updateDate()
							}
						}
					}
					.presentationDetents([.medium])
					.interactiveDismissDisabled()
					.onAppear {
						editDateValue = mealPlan.date
						editMealTypeValue = mealPlan.mealType
					}
				}
			}
			.sheet(isPresented: $editRecipe) {
				NavigationStack {
					List {
						if recipes.isEmpty {
							ContentUnavailableView {
								Label("No recipes yet", image: "basket.badge.questionmark")
							} description: {
								Text("Create a recipe to start planning meals")
							}
						} else {
							ForEach(recipes, id: \.self) { recipe in
								Text(recipe.name)
									.multilineTextAlignment(.leading)
									.foregroundStyle(.white)
									.bold()
									.frame(maxWidth: .infinity, alignment: .leading)
									.listRowSeparator(.hidden)
									.listRowBackground(Color.convertStringToColor(recipe.color))
									.contentShape(Rectangle())
									.onTapGesture {
										updateRecipe(recipe)
									}
							}
						}
					}
					.navigationTitle("Recipes")
					.navigationBarTitleDisplayMode(.inline)
					.toolbar {
						ToolbarItem(placement: .topBarLeading) {
							Button(role: .close) {
								editRecipe.toggle()
							}
						}
					}
					.presentationDetents([.medium, .large])
					.interactiveDismissDisabled()
				}
			}
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Menu {
						Button("Delete Meal Plan", systemImage: "trash", role: .destructive) {
							deleteConfirmationDialog.toggle()
							settingsStore.triggerHaptic(&hapticWarning)
						}
					} label: {
						Image(systemName: "ellipsis")
					}
					.confirmationDialog("Delete Meal Plan?", isPresented: $deleteConfirmationDialog, titleVisibility: .hidden) {
						Button("Delete Meal Plan", role: .destructive) {
							deleteMealPlan()
						}
					} message: {
						Text("This meal plan will be deleted. This action can’t be undone.")
					}
				}
			}
			.presentationDetents([.large])
			.interactiveDismissDisabled()
			.sensoryFeedback(.warning, trigger: hapticWarning)
			.sensoryFeedback(.success, trigger: [hapticDeleted, hapticSaved])
		}
	}
}

#Preview {
	MealPlannerItem(mealPlan: MealPlan(recipe: Recipe(ingredients: [])))
}

// MARK: - utilities
extension MealPlannerItem {
	
	private func updateDate() {
		mealPlan.date = editDateValue
		mealPlan.mealType = editMealTypeValue
		
		editDate.toggle()
		settingsStore.triggerHaptic(&hapticSaved)
		AnalyticsUtils.logButtonTap(screen: .mealPlanItem, button: .edit)
	}
	
	private func updateRecipe(_ recipe: Recipe) {
		mealPlan.recipe = recipe
		mealPlan.recipeName = recipe.name
		
		editRecipe.toggle()
		settingsStore.triggerHaptic(&hapticSaved)
		AnalyticsUtils.logButtonTap(screen: .mealPlanItem, button: .edit)
	}
	
	private func deleteMealPlan() {
		
		AnalyticsUtils.logButtonTap(screen: .mealPlanItem, button: .delete)
		settingsStore.triggerHaptic(&hapticDeleted)
		dismiss()
		
		DispatchQueue.main.async {
			
			modelContext.delete(mealPlan)
			
			do {
				try modelContext.save()
			} catch {
				print("Error removing meal plan: \(error.localizedDescription)")
			}
			
		}
		
	}
}

// MARK: - views
extension MealPlannerItem {
	
	@ViewBuilder
	private var mealPlanDateView: some View {
		LabeledContent {
			VStack(alignment: .trailing, spacing: 3) {
				
				Text(mealPlan.mealType.rawValue.lowercased())
					.font(.caption)
				
				Text("\(mealPlan.date, format: .dateTime.weekday(.wide).day().month(.wide).year())")
					.foregroundStyle(.primary)
				
			}
		} label: {
			mealPlan.mealType.image
				.foregroundStyle(.white)
				.listRoundedIconStyle(bgc: mealPlan.mealType.color, filledIconStyle: true)
				.font(.subheadline)
		}
		.contentShape(Rectangle())
		.onTapGesture {
			editDate.toggle()
		}
	}
	
	@ViewBuilder
	private var recipeNameView: some View {
		Text(mealPlan.recipe?.name ?? mealPlan.recipeName)
			.multilineTextAlignment(.trailing)
			.foregroundStyle(.white)
			.bold()
			.frame(maxWidth: .infinity, alignment: .trailing)
			.listRowBackground(Color.convertStringToColor(mealPlan.recipe?.color ?? "appleRed"))
			.listRowSeparator(.hidden, edges: .bottom)
			.contentShape(Rectangle())
			.onTapGesture {
				editRecipe.toggle()
			}
	}
	
	@ViewBuilder
	private var recipeDetailsView: some View {
		if let recipe = mealPlan.recipe {
			
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
				if recipe.instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
					Text("No instructions available")
						.foregroundStyle(.secondary)
				} else {
					Text(recipe.instructions)
				}
			} label: {
				Text("Instructions")
			}
			
		}
	}
	
}

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
	
	@State private var deleteConfirmationDialog = false
	
	@State private var hapticWarning = false
	@State private var hapticDeleted = false
	@State private var hapticSaved = false
	
	// MARK: - body
	var body: some View {
		NavigationStack {
			Form {
				
				Section {
					mealPlanDateView
				} header: {
					if settingsStore.hideEditTip == false {
						Label("Swipe left to edit fields", systemImage: "info.bubble")
							.font(.footnote)
					}
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
			.navigationBarTitleDisplayMode(.inline)
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
					.presentationDetents([.medium, .large])
					.interactiveDismissDisabled()
					.onAppear {
						editDateValue = mealPlan.date
						editMealTypeValue = mealPlan.mealType
					}
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
							removeMealPlan()
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

	private func removeMealPlan() {
		Task {
			try await Task.sleep(
				until: .now + .nanoseconds(33),
				tolerance: .seconds(1),
				clock: .suspending
			)
			deleteMealPlan()
		}
	}
	
	private func deleteMealPlan() {
		
		dismiss()
		
		DispatchQueue.main.async {
			modelContext.delete(mealPlan)
			
			do {
				try modelContext.save()
			} catch {
				print("Error removing folder: \(error.localizedDescription)")
			}
			
			settingsStore.triggerHaptic(&hapticDeleted)
			AnalyticsUtils.logButtonTap(screen: .mealPlanItem, button: .delete)
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
		.swipeActions(edge: .trailing, allowsFullSwipe: true) {
			Button {
				settingsStore.hideEditTipView()
				editDate.toggle()
			} label: {
				Label("Edit", systemImage: "pencil")
			}
			.tint(.appleOrange)
		}
	}
	
	@ViewBuilder
	private var recipeNameView: some View {
		Text(mealPlan.recipe.name)
			.multilineTextAlignment(.trailing)
			.foregroundStyle(.white)
			.bold()
			.frame(maxWidth: .infinity, alignment: .trailing)
			.listRowBackground(Color.convertStringToColor(mealPlan.recipe.color))
			.listRowSeparator(.hidden, edges: .bottom)
		
//		LabeledContent {
//			Text(mealPlan.recipe.name)
//				.multilineTextAlignment(.trailing)
//		} label: {
//			Image(systemName: "fork.knife")
//		}
//		.foregroundStyle(.white)
//		.bold()
//		.listRowBackground(Color.convertStringToColor(mealPlan.recipe.color))
//		.listRowSeparator(.hidden, edges: .bottom)
		
	}
	
	@ViewBuilder
	private var recipeDetailsView: some View {
		
		DisclosureGroup {
				if mealPlan.recipe.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
					
					Text("No notes available")
						.foregroundStyle(.secondary)
					
				} else {
					
					Text(mealPlan.recipe.notes)
					
				}
		} label: {
			Text("Notes")
		}
		
		DisclosureGroup {
			
			LabeledContent {
				HStack {
					Text(mealPlan.recipe.prepTime, format: .number)
					Text(mealPlan.recipe.prepTime != 1 ? "Minutes" : "Minute")
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
					Text(mealPlan.recipe.cookTime, format: .number)
					Text(mealPlan.recipe.cookTime != 1 ? "Minutes" : "Minute")
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
					Text(mealPlan.recipe.servings, format: .number)
					Text(mealPlan.recipe.servings != 1 ? "Persons" : "Person")
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
			
			if mealPlan.recipe.ingredients.isEmpty {
				
				Text("No ingredients")
					.foregroundStyle(.secondary)
				
			} else {
				
				ForEach(mealPlan.recipe.ingredients.sorted(by: { $0.name < $1.name})) { recipeIngredient in
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
				if mealPlan.recipe.instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
					
					Text("No instructions available")
						.foregroundStyle(.secondary)
					
				} else {
					
					Text(mealPlan.recipe.instructions)
					
				}
			}
			
		} label: {
			Text("Instructions")
		}
		
	}
	
}

//
//  RecipesAdd.swift
//  BoobooBites
//
//  Created by Ryan Rook on 20/03/2026.
//

import SwiftUI
import SwiftData

struct RecipesAdd: View {
	
	// MARK: - properties
	@Binding var isPresented: Bool
	
	@Environment(SettingsStore.self) private var settingsStore
	
	@Environment(\.modelContext) private var modelContext
	
	@State private var name: String = ""
	@FocusState private var nameIsFocused: Bool
	
	@State private var notes: String = ""
	
	@State var selectedColor: Color = .appleRed
	
	@Query(sort: \Ingredient.name, order: .forward) private var storedIngredients: [Ingredient]
	
	@State private var ingredients: [RecipeIngredient] = []
	
	@State private var instructions: String = ""
	
	@State private var prepTime: Int? = nil
	@State private var cookTime: Int? = nil
	@State private var servings: Int? = nil
	
	let numberFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .none
		return formatter
	}()
	
	let decimalFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		return formatter
	}()
	
	@State private var newIngredient = false
	@State private var addStoredIngredient = false
	
	@State private var hapticSaved = false
	
	@State private var showPaywall = false
	
	// MARK: - body
    var body: some View {
		NavigationStack {
			Form {
				
				Section {
					
					TextField("Name", text: $name)
						.keyboardType(.default)
						.bold()
						.focused($nameIsFocused)
						.textInputAutocapitalization(.words)
						.textFieldLimiter(text: $name, limit: 32)
					
					TextField("Notes", text: $notes, axis: .vertical)
						.keyboardType(.default)
						.textInputAutocapitalization(.sentences)
					
					ColorPickerView(selectedColor: $selectedColor)
					
				}
				
				Section {
					
					LabeledContent {
						TextField(prepTime != 1 ? "Minutes" : "Minute", value: $prepTime, formatter: numberFormatter)
							.keyboardType(.numberPad)
							.multilineTextAlignment(.trailing)
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
						TextField(cookTime != 1 ? "Minutes" : "Minute", value: $cookTime, formatter: numberFormatter)
							.keyboardType(.numberPad)
							.multilineTextAlignment(.trailing)
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
						TextField(servings != 1 ? "Persons" : "Person", value: $servings, formatter: numberFormatter)
							.keyboardType(.numberPad)
							.multilineTextAlignment(.trailing)
					} label: {
						HStack {
							Image(systemName: "circle")
								.symbolVariant(.fill)
								.font(.caption)
								.foregroundStyle(.recipeServings.gradient)
							Text("Servings")
						}
					}
					
				}
				
				Section {
					
					if ingredients.count > 0 {
						ForEach(ingredients.indices.sorted { ingredients[$0].name < ingredients[$1].name }, id: \.self ) { index in
							
							LabeledContent {
								Picker("Unit", selection: $ingredients[index].unit) {
									ForEach(UnitType.allCases, id: \.self) { unit in
										Text(unit.rawValue.lowercased()).tag(unit)
									}
								}
								.tint(.accent)
								.labelsHidden()
							} label: {
								HStack {
									Image(systemName: "circle")
										.symbolVariant(.fill)
										.font(.caption)
										.foregroundStyle(Color.convertStringToColor(ingredients[index].color).gradient)
									Text(ingredients[index].name)
								}
							}
							.listRowSeparator(.hidden)
							.listRowSpacing(0)
							.swipeActions(edge: .trailing, allowsFullSwipe: false) {
								Button(role: .destructive) {
									withAnimation {
										ingredients.removeAll(where: { $0.id == ingredients[index].id })
									}
								}
							}
							
							TextField("unit value", value: $ingredients[index].amount, formatter: decimalFormatter)
								.keyboardType(.decimalPad)
								.multilineTextAlignment(.trailing)
								.padding(12)
								.glassEffectStyle()
								.listRowInsets(.init(top: 0, leading: 9, bottom: 9, trailing: 9))
								.listRowSeparator(ingredients[index].id == ingredients.sorted { $0.name < $1.name }.last?.id ? .hidden : .visible)
							
						}
					}

				} header: {
					HStack {
						
						Text("Ingredients")
						
						Spacer()
						
						if availableIngredients.isEmpty {
							
							Button {
								createNewIngredient()
							} label: {
								Image(systemName: "plus")
							}
							
						} else {
							
							Menu {
								
								Button {
									addStoredIngredient.toggle()
								} label: {
									Label("Stored Ingredients (\(availableIngredients.count))", systemImage: "carrot")
								}
								.disabled(availableIngredients.isEmpty)
								
								Divider()
								
								Button {
									createNewIngredient()
								} label: {
									Label("Create New", systemImage: "plus")
								}
								
							} label: {
								Image(systemName: "plus")
							}
							
						}
						
					}
				}
				
				Section {
					
					TextField("Instructions", text: $instructions, axis: .vertical)
						.keyboardType(.default)
						.textInputAutocapitalization(.sentences)
					
				} header: {
					
					Text("Instructions")
					
				}
				
			}
			.navigationTitle("New Recipe")
			.toolbarTitleDisplayMode(.inline)
			.scrollDismissesKeyboard(.interactively)
			.sheet(isPresented: $newIngredient) {
				IngredientsAdd(isPresented: $newIngredient) { ingredient in
					addNewIngredient(ingredient)
				}
			}
			.sheet(isPresented: $addStoredIngredient) {
				IngredientsMultiPicker(isPresented: $addStoredIngredient, storedIngredients: availableIngredients) { pickedIngredients in
					addPickedIngredients(pickedIngredients)
				}
			}
			.toolbar {
				
				ToolbarItem(placement: .topBarLeading) {
					Button(role: .close) {
						isPresented.toggle()
					}
				}
				
				ToolbarItem(placement: .primaryAction) {
					Button(role: .confirm) {
						saveNewRecipe()
					}
					.disabled(disabledToSave())
				}
				
			}
			.showPaywall(showPaywallMessage: $showPaywall, paywallMessage: .ingredients)
			.presentationDetents([.large])
			.interactiveDismissDisabled()
			.onAppear { nameIsFocused = true }
			.sensoryFeedback(.success, trigger: hapticSaved)
		}
    }
}

#Preview {
	RecipesAdd(isPresented: .constant(false))
}

// MARK: - utilities
extension RecipesAdd {
	
	private func reachFreeIngredientsLimit() -> Bool {
		if storedIngredients.count >= 25 && !ProAccessManager.premiumPurchased { return true } else { return false }
	}
	
	private func createNewIngredient() {
		switch reachFreeIngredientsLimit() {
		case true: showPaywall.toggle()
		case false: newIngredient.toggle()
		}
	}
	
	private var availableIngredients: [Ingredient] {
		let selectedIDs = Set(ingredients.map { $0.sourceIngredientID })
		
		return storedIngredients.filter {
			!selectedIDs.contains($0.id)
		}
	}
	
	private func addNewIngredient(_ ingredient: Ingredient) {
		withAnimation {
			ingredients.append(RecipeIngredient(name: ingredient.name, color: ingredient.color, unit: ingredient.defaultUnit, amount: ingredient.defaultUnit.defaultValue, sourceIngredientID: ingredient.id))
		}
	}
	
	private func addPickedIngredients(_ pickedIngredients: [Ingredient]) {
		pickedIngredients.forEach { ingredient in
			withAnimation {
				ingredients.append(RecipeIngredient(name: ingredient.name, color: ingredient.color, unit: ingredient.defaultUnit, amount: ingredient.defaultUnit.defaultValue, sourceIngredientID: ingredient.id))
			}
		}
	}
	
	private func disabledToSave() -> Bool {
		if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			return true
		} else {
			return false
		}
	}
	
	func saveNewRecipe() {
		let recipe = Recipe(
			name: name.trimmingCharacters(in: .whitespacesAndNewlines),
			notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
			color: Color.convertColorToString(selectedColor),
			instructions: instructions.trimmingCharacters(in: .whitespacesAndNewlines),
			prepTime: prepTime ?? 0,
			cookTime: cookTime ?? 0,
			servings: servings ?? 0,
			ingredients: ingredients
		)

		modelContext.insert(recipe)

		do {
			try? modelContext.save()
		}
		
		isPresented.toggle()
		settingsStore.triggerHaptic(&hapticSaved)
		AnalyticsUtils.logButtonTap(screen: .recipeAdd, button: .save)
	}
	
}

//
//  RecipesItem.swift
//  BoobooBites
//
//  Created by Ryan Rook on 21/03/2026.
//

import SwiftUI
import SwiftData

struct RecipesItem: View {
	
	// MARK: - properties
	@Environment(SettingsStore.self) private var settingsStore
	
	@Environment(\.modelContext) private var modelContext
	
	@Environment(\.dismiss) var dismiss
	
	@State var recipe: Recipe
	
	@State private var showNotes = false
	@State private var showDetails = true
	@State private var showIngredients = true
	@State private var showInstructions = true
	
	@State private var editName = false
	@State private var editNameValue = ""
	
	@State private var editNotes = false
	@State private var editNotesValue = ""
	
	@State var selectedColor: Color = .appleRed
	
	@State private var editPreptime = false
	@State private var editPreptimeValue: Int = 1
	
	@State private var editCooktime = false
	@State private var editCooktimeValue: Int = 1
	
	@State private var editServings = false
	@State private var editServingsValue: Int = 1
	
	@State private var editIngredient: RecipeIngredient? = nil
	@State private var editIngredientUnit: UnitType = .grams
	@State private var editIngredientUnitValue: Double = 1
	
	@State private var newIngredient = false
	@State private var addStoredIngredient = false
	
	@State private var editInstructions = false
	@State private var editInstructionsValue = ""
	
	@Query(sort: \Ingredient.name, order: .forward) private var storedIngredients: [Ingredient]
	
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
	
	@State private var deleteConfirmationDialog = false
	
	@State private var hapticWarning = false
	@State private var hapticDeleted = false
	@State private var hapticSaved = false
	
	@State private var showPaywall = false
	
	// MARK: - body
	var body: some View {
		NavigationStack {
			Form {
				
				Section {
					
					Text(recipe.name)
						.multilineTextAlignment(.leading)
						.foregroundStyle(.white)
						.bold()
						.frame(maxWidth: .infinity, alignment: .trailing)
						.listRowBackground(Color.convertStringToColor(recipe.color))
						.listRowSeparator(.hidden, edges: .bottom)
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							Button {
								settingsStore.hideRecipeItemTooltip()
								editName.toggle()
							} label: {
								Label("Edit", systemImage: "pencil")
							}
							.tint(.appleOrange)
						}
					
//					LabeledContent {
//						Text(recipe.name)
//							.multilineTextAlignment(.trailing)
//					} label: {
//						Image(systemName: "fork.knife")
//					}
//					.foregroundStyle(.white)
//					.bold()
//					.listRowBackground(Color.convertStringToColor(recipe.color))
//					.listRowSeparator(.hidden, edges: .bottom)
//					.swipeActions(edge: .trailing, allowsFullSwipe: true) {
//						Button {
//							editName.toggle()
//						} label: {
//							Label("Edit", systemImage: "pencil")
//						}
//						.tint(.appleOrange)
//					}
					
					DisclosureGroup(isExpanded: $showNotes) {
						Group {
							if recipe.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
								
								Text("No notes available")
									.foregroundStyle(.secondary)
								
							} else {
								
								Text(recipe.notes)
								
							}
						}
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							Button {
								settingsStore.hideRecipeItemTooltip()
								editNotes.toggle()
							} label: {
								Label("Edit", systemImage: "pencil")
							}
							.tint(.appleOrange)
						}
					} label: {
						Text("Notes")
					}
					
					Toggle("Favorite", isOn: $recipe.isFavorite)
					
				} header: {
					if settingsStore.hideTooltipRecipeItem == false {
						Label("Swipe left to edit fields", systemImage: "info.bubble")
							.font(.footnote)
					}
				}
				
				Section {
					
					DisclosureGroup(isExpanded: $showDetails) {
						
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
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							Button {
								settingsStore.hideRecipeItemTooltip()
								editPreptime.toggle()
							} label: {
								Label("Edit", systemImage: "pencil")
							}
							.tint(.appleOrange)
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
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							Button {
								settingsStore.hideRecipeItemTooltip()
								editCooktime.toggle()
							} label: {
								Label("Edit", systemImage: "pencil")
							}
							.tint(.appleOrange)
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
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							Button {
								settingsStore.hideRecipeItemTooltip()
								editServings.toggle()
							} label: {
								Label("Edit", systemImage: "pencil")
							}
							.tint(.appleOrange)
						}
						
					} label: {
						Text("Details")
					}
					
				}
				
				Section {
					DisclosureGroup(isExpanded: $showIngredients) {
						if recipe.ingredients.isEmpty {
							
							Text("No ingredients")
								.foregroundStyle(.secondary)
							
						} else {
							
							ForEach(recipe.ingredients.sorted(by: { $0.ingredient.name < $1.ingredient.name})) { recipeIngredient in
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
											.foregroundStyle(Color.convertStringToColor(recipeIngredient.ingredient.color).gradient)
										Text(recipeIngredient.ingredient.name)
									}
								}
								.swipeActions(edge: .trailing, allowsFullSwipe: true) {
									
									Button {
										settingsStore.hideRecipeItemTooltip()
										editIngredient = recipeIngredient
									} label: {
										Label("Edit", systemImage: "pencil")
									}
									.tint(.appleOrange)
									
									Button(role: .destructive) {
										withAnimation {
											recipe.ingredients.removeAll(where: { $0.id == recipeIngredient.id })
										}
									}
								}
							}
							
						}
					} label: {
						Text("Ingredients")
					}
					
					if showIngredients {
						
						if availableIngredients.isEmpty {
							
							Button {
								createNewIngredient()
							} label: {
								Image(systemName: "plus")
									.symbolVariant(.circle.fill)
									.foregroundStyle(.white)
							}
							.frame(maxWidth: .infinity, alignment: .trailing)
							.listRowBackground(Color.accent)
							
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
									.symbolVariant(.circle.fill)
									.foregroundStyle(.white)
									.frame(maxWidth: .infinity, alignment: .trailing)
							}
							.listRowBackground(Color.accent)
							
						}
						
					}
					
				}
				
				Section {
					
					DisclosureGroup(isExpanded: $showInstructions) {
						Group {
							if recipe.instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
								
								Text("No instructions available")
									.foregroundStyle(.secondary)
								
							} else {
								
								Text(recipe.instructions)
								
							}
						}
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							Button {
								settingsStore.hideRecipeItemTooltip()
								editInstructions.toggle()
							} label: {
								Label("Edit", systemImage: "pencil")
							}
							.tint(.appleOrange)
						}
					} label: {
						Text("Instructions")
					}
					
				}
				
			}
			.navigationTitle("Recipe")
			.navigationSubtitle("\(recipe.ingredients.count) \(recipe.ingredients.count != 1 ? "ingredients" : "ingredient")")
//			.navigationBarTitleDisplayMode(.inline)
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
			.sheet(isPresented: $editName) {
				NavigationStack {
					Form {
						
						TextField("Name", text: $editNameValue)
							.keyboardType(.default)
							.bold()
							.textInputAutocapitalization(.words)
							.textFieldLimiter(text: $editNameValue, limit: 32)
						
						ColorPickerView(selectedColor: $selectedColor)
						
					}
					.navigationTitle("Name")
					.navigationBarTitleDisplayMode(.inline)
					.scrollDismissesKeyboard(.interactively)
					.toolbar {
						ToolbarItem(placement: .topBarLeading) {
							Button(role: .close) {
								editName.toggle()
							}
						}
						ToolbarItem(placement: .primaryAction) {
							Button(role: .confirm) {
								recipe.name = editNameValue.trimmingCharacters(in: .whitespacesAndNewlines)
								recipe.color = Color.convertColorToString(selectedColor)
								editName.toggle()
								settingsStore.triggerHaptic(&hapticSaved)
								saveLastUpdatedDate()
							}
							.disabled(editNameValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
						}
					}
					.presentationDetents([.medium, .large])
					.interactiveDismissDisabled()
					.onAppear {
						editNameValue = recipe.name
						selectedColor = Color.convertStringToColor(recipe.color)
					}
				}
			}
			.sheet(isPresented: $editNotes) {
				NavigationStack {
					Form {
						TextField("Notes", text: $editNotesValue, axis: .vertical)
							.keyboardType(.default)
							.textInputAutocapitalization(.sentences)
					}
					.navigationTitle("Notes")
					.navigationBarTitleDisplayMode(.inline)
					.scrollDismissesKeyboard(.interactively)
					.toolbar {
						ToolbarItem(placement: .topBarLeading) {
							Button(role: .close) {
								editNotes.toggle()
							}
						}
						ToolbarItem(placement: .primaryAction) {
							Button(role: .confirm) {
								recipe.notes = editNotesValue.trimmingCharacters(in: .whitespacesAndNewlines)
								editNotes.toggle()
								settingsStore.triggerHaptic(&hapticSaved)
								saveLastUpdatedDate()
							}
						}
					}
					.presentationDetents([.medium, .large])
					.interactiveDismissDisabled()
					.onAppear { editNotesValue = recipe.notes }
				}
			}
			.sheet(isPresented: $editPreptime) {
				NavigationStack {
					Form {
						LabeledContent {
							TextField(editPreptimeValue != 1 ? "Minutes" : "Minute", value: $editPreptimeValue, formatter: numberFormatter)
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
					}
					.navigationTitle("Prep Time")
					.navigationBarTitleDisplayMode(.inline)
					.scrollDismissesKeyboard(.interactively)
					.toolbar {
						ToolbarItem(placement: .topBarLeading) {
							Button(role: .close) {
								editPreptime.toggle()
							}
						}
						ToolbarItem(placement: .primaryAction) {
							Button(role: .confirm) {
								recipe.prepTime = editPreptimeValue
								editPreptime.toggle()
								settingsStore.triggerHaptic(&hapticSaved)
								saveLastUpdatedDate()
							}
						}
					}
					.presentationDetents([.medium, .large])
					.interactiveDismissDisabled()
					.onAppear {
						editPreptimeValue = recipe.prepTime
					}
				}
			}
			.sheet(isPresented: $editCooktime) {
				NavigationStack {
					Form {
						LabeledContent {
							TextField(editCooktimeValue != 1 ? "Minutes" : "Minute", value: $editCooktimeValue, formatter: numberFormatter)
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
					}
					.navigationTitle("Cook Time")
					.navigationBarTitleDisplayMode(.inline)
					.scrollDismissesKeyboard(.interactively)
					.toolbar {
						ToolbarItem(placement: .topBarLeading) {
							Button(role: .close) {
								editCooktime.toggle()
							}
						}
						ToolbarItem(placement: .primaryAction) {
							Button(role: .confirm) {
								recipe.cookTime = editCooktimeValue
								editCooktime.toggle()
								settingsStore.triggerHaptic(&hapticSaved)
								saveLastUpdatedDate()
							}
						}
					}
					.presentationDetents([.medium, .large])
					.interactiveDismissDisabled()
					.onAppear {
						editCooktimeValue = recipe.cookTime
					}
				}
			}
			.sheet(isPresented: $editServings) {
				NavigationStack {
					Form {
						LabeledContent {
							TextField(editServingsValue != 1 ? "Minutes" : "Minute", value: $editServingsValue, formatter: numberFormatter)
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
					.navigationTitle("Servings")
					.navigationBarTitleDisplayMode(.inline)
					.scrollDismissesKeyboard(.interactively)
					.toolbar {
						ToolbarItem(placement: .topBarLeading) {
							Button(role: .close) {
								editServings.toggle()
							}
						}
						ToolbarItem(placement: .primaryAction) {
							Button(role: .confirm) {
								recipe.servings = editServingsValue
								editServings.toggle()
								settingsStore.triggerHaptic(&hapticSaved)
								saveLastUpdatedDate()
							}
						}
					}
					.presentationDetents([.medium, .large])
					.interactiveDismissDisabled()
					.onAppear {
						editServingsValue = recipe.servings
					}
				}
			}
			.sheet(item: $editIngredient, onDismiss: {
				editIngredient = nil
			}, content: { editableIngredient in
				NavigationStack {
					Form {
						Section {
							
							HStack {
								Image(systemName: "circle")
									.symbolVariant(.fill)
									.font(.caption)
									.foregroundStyle(Color.convertStringToColor(editableIngredient.ingredient.color).gradient)
								Text(editableIngredient.ingredient.name)
							}
							
							LabeledContent {
								Picker("Unit", selection: $editIngredientUnit) {
									ForEach(UnitType.allCases, id: \.self) { unit in
										Text(unit.rawValue.lowercased()).tag(unit)
									}
								}
								.tint(.accent)
								.labelsHidden()
							} label: {
								TextField("unit value", value: $editIngredientUnitValue, formatter: decimalFormatter)
									.keyboardType(.decimalPad)
									.multilineTextAlignment(.trailing)
							}
							
						}
					}
					.navigationTitle("Ingredient")
					.navigationBarTitleDisplayMode(.inline)
					.scrollDismissesKeyboard(.interactively)
					.toolbar {
						ToolbarItem(placement: .topBarLeading) {
							Button(role: .close) {
								editIngredient = nil
							}
						}
						ToolbarItem(placement: .primaryAction) {
							Button(role: .confirm) {
								if let ingredient = recipe.ingredients.first(where: { $0.id == editableIngredient.id }) {
									ingredient.unit = editIngredientUnit
									ingredient.amount = editIngredientUnitValue
								}
								editIngredient = nil
								settingsStore.triggerHaptic(&hapticSaved)
								saveLastUpdatedDate()
							}
						}
					}
					.presentationDetents([.medium, .large])
					.interactiveDismissDisabled()
					.onAppear {
						editIngredientUnit = editableIngredient.unit
						editIngredientUnitValue = editableIngredient.amount
					}
				}
			})
			.sheet(isPresented: $editInstructions) {
				NavigationStack {
					Form {
						TextField("Instructions", text: $editInstructionsValue, axis: .vertical)
							.keyboardType(.default)
							.textInputAutocapitalization(.sentences)
					}
					.navigationTitle("Instructions")
					.navigationBarTitleDisplayMode(.inline)
					.scrollDismissesKeyboard(.interactively)
					.toolbar {
						ToolbarItem(placement: .topBarLeading) {
							Button(role: .close) {
								editInstructions.toggle()
							}
						}
						ToolbarItem(placement: .primaryAction) {
							Button(role: .confirm) {
								recipe.instructions = editInstructionsValue.trimmingCharacters(in: .whitespacesAndNewlines)
								editInstructions.toggle()
								settingsStore.triggerHaptic(&hapticSaved)
								saveLastUpdatedDate()
							}
						}
					}
					.presentationDetents([.medium, .large])
					.interactiveDismissDisabled()
					.onAppear { editInstructionsValue = recipe.instructions }
				}
			}
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Menu {
						Button("Delete Recipe", systemImage: "trash", role: .destructive) {
							deleteConfirmationDialog.toggle()
							settingsStore.triggerHaptic(&hapticWarning)
						}
					} label: {
						Image(systemName: "ellipsis")
					}
					.confirmationDialog("Delete Recipe?", isPresented: $deleteConfirmationDialog, titleVisibility: .hidden) {
						Button("Delete Recipe", role: .destructive) {
							removeRecipe(recipe)
						}
					} message: {
						Text("Deleted recipes will be removed from existing meal plans. This action cannot be recovered.")
					}
				}
			}
			.sensoryFeedback(.warning, trigger: hapticWarning)
			.sensoryFeedback(.success, trigger: [hapticDeleted, hapticSaved])
			.showPaywall(showPaywallMessage: $showPaywall, paywallMessage: .ingredients)
		}
	}
}

#Preview {
	RecipesItem(recipe: Recipe(name: "Curry", ingredients: []))
}

// MARK: - utilities
extension RecipesItem {
	
	private func reachFreeIngredientsLimit() -> Bool {
		if storedIngredients.count >= 12 && !ProAccessManager.premiumPurchased { return true } else { return false }
	}
	
	private func createNewIngredient() {
		switch reachFreeIngredientsLimit() {
		case true: showPaywall.toggle()
		case false: newIngredient.toggle()
		}
	}
	
	private func saveLastUpdatedDate() {
		recipe.lastUpdated = Date()
	}
	
	private var availableIngredients: [Ingredient] {
		let selectedIDs = Set(recipe.ingredients.map { $0.ingredient.id })
		
		return storedIngredients.filter {
			!selectedIDs.contains($0.id)
		}
	}
	
	private func addNewIngredient(_ ingredient: Ingredient) {
		withAnimation {
			recipe.ingredients.append(RecipeIngredient(ingredient: ingredient, unit: ingredient.defaultUnit))
		}
		saveLastUpdatedDate()
	}
	
	private func addPickedIngredients(_ pickedIngredients: [Ingredient]) {
		pickedIngredients.forEach { ingredient in
			withAnimation {
				recipe.ingredients.append(RecipeIngredient(ingredient: ingredient, unit: ingredient.defaultUnit))
			}
		}
		saveLastUpdatedDate()
	}

	private func removeRecipe(_ recipe: Recipe) {
		Task {
			try await Task.sleep(
				until: .now + .nanoseconds(33),
				tolerance: .seconds(1),
				clock: .suspending
			)
			deleteRecipe(recipe)
		}
	}
	
	private func deleteRecipe(_ recipe: Recipe) {
		
		modelContext.delete(recipe)
		
		do {
			try modelContext.save()
		} catch {
			print("Error removing folder: \(error.localizedDescription)")
		}
		
		dismiss()
		settingsStore.triggerHaptic(&hapticDeleted)
	}
}

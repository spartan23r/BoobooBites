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
	@State private var editIngredientNameValue = ""
	@State private var editIngredientUnit: UnitType = .grams
	@State private var editIngredientUnitValue: Double = 100
	@State private var editIngredientNotesValue: String = ""
	
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
	
	@State private var toastCopiedNote = false
	@State private var toastCopiedInstructions = false
	
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
						.contentShape(Rectangle())
						.onTapGesture {
							editName.toggle()
						}
					
					DisclosureGroup(isExpanded: $showNotes) {
						Group {
							if recipe.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
								
								Text("No notes available")
									.foregroundStyle(.secondary)
								
							} else {
								
								Text(recipe.notes)
								
							}
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							Button {
								XPasteboard.general.copyText(recipe.notes)
								settingsStore.triggerHaptic(&hapticSaved)
								AnalyticsUtils.logButtonTap(screen: .recipeItem, button: .copyNotes)
								showToastCopiedNote()
							} label: {
								Label("Copy", systemImage: "document.on.clipboard")
							}
							.tint(recipe.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .appleGray : .appleBlue)
							.disabled(recipe.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
						}
						.contentShape(Rectangle())
						.onTapGesture {
							editNotes.toggle()
						}
					} label: {
						Text("Notes")
					}
					
					
					LabeledContent("Used in meal plans", value: attachedMealPlansCount(), format: .number)
					
					Toggle("Favorite", isOn: $recipe.isFavorite)
					
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
						.contentShape(Rectangle())
						.onTapGesture {
							editPreptime.toggle()
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
						.contentShape(Rectangle())
						.onTapGesture {
							editCooktime.toggle()
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
						.contentShape(Rectangle())
						.onTapGesture {
							editServings.toggle()
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
								.contentShape(Rectangle())
								.onTapGesture {
									editIngredient = recipeIngredient
								}
								.swipeActions(edge: .trailing, allowsFullSwipe: false) {
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
						.frame(maxWidth: .infinity, alignment: .leading)
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							Button {
								XPasteboard.general.copyText(recipe.instructions)
								settingsStore.triggerHaptic(&hapticSaved)
								AnalyticsUtils.logButtonTap(screen: .recipeItem, button: .copyInstructions)
								showToastCopiedInstructions()
							} label: {
								Label("Copy", systemImage: "document.on.clipboard")
							}
							.tint(recipe.instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .appleGray : .appleBlue)
							.disabled(recipe.instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
						}
						.contentShape(Rectangle())
						.onTapGesture {
							editInstructions.toggle()
						}
					} label: {
						Text("Instructions")
					}
					
				}
				
			}
			.navigationTitle("Recipe")
			.navigationSubtitle("\(recipe.ingredients.count) \(recipe.ingredients.count != 1 ? "ingredients" : "ingredient")")
			.toolbarTitleDisplayMode(.large)
			.toastMessage(isActive: $toastCopiedNote, color: .appleBlue, title: "Note Copied", image: "document.on.clipboard")
			.toastMessage(isActive: $toastCopiedInstructions, color: .appleBlue, title: "Instructions Copied", image: "document.on.clipboard")
			.scrollDismissesKeyboard(.interactively)
			.sheet(isPresented: $newIngredient) {
				IngredientsAdd(isPresented: $newIngredient, fromRecipeScreen: true) { recipeIngredient in
					withAnimation {
						recipe.ingredients.append(recipeIngredient)
					}
					saveLastUpdatedDate()
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
								AnalyticsUtils.logButtonTap(screen: .recipeItem, button: .edit)
								saveLastUpdatedDate()
							}
							.disabled(editNameValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
						}
					}
					.presentationDetents([.large])
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
								AnalyticsUtils.logButtonTap(screen: .recipeItem, button: .edit)
								saveLastUpdatedDate()
							}
						}
					}
					.presentationDetents([.large])
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
								AnalyticsUtils.logButtonTap(screen: .recipeItem, button: .edit)
								saveLastUpdatedDate()
							}
						}
					}
					.presentationDetents([.large])
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
								AnalyticsUtils.logButtonTap(screen: .recipeItem, button: .edit)
								saveLastUpdatedDate()
							}
						}
					}
					.presentationDetents([.large])
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
								AnalyticsUtils.logButtonTap(screen: .recipeItem, button: .edit)
								saveLastUpdatedDate()
							}
						}
					}
					.presentationDetents([.large])
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
							
							TextField("Name", text: $editIngredientNameValue)
								.keyboardType(.default)
								.bold()
								.textInputAutocapitalization(.words)
								.textFieldLimiter(text: $editIngredientNameValue, limit: 32)
							
							TextField("Notes", text: $editIngredientNotesValue, axis: .vertical)
								.keyboardType(.default)
								.textInputAutocapitalization(.sentences)
							
							ColorPickerView(selectedColor: $selectedColor)
							
						}
						
						Section {
							
							Picker("Unit", selection: $editIngredientUnit) {
								ForEach(UnitType.allCases, id: \.self) { unit in
									Text(unit.rawValue.lowercased()).tag(unit)
								}
							}
							.frame(maxWidth: .infinity, alignment: .trailing)
							.tint(.accent)
							
							TextField("unit value", value: $editIngredientUnitValue, formatter: decimalFormatter)
								.keyboardType(.decimalPad)
								.multilineTextAlignment(.trailing)
							
//							LabeledContent {
//								Picker("Unit", selection: $editIngredientUnit) {
//									ForEach(UnitType.allCases, id: \.self) { unit in
//										Text(unit.rawValue.lowercased()).tag(unit)
//									}
//								}
//								.tint(.accent)
//								.labelsHidden()
//							} label: {
//								TextField("unit value", value: $editIngredientUnitValue, formatter: decimalFormatter)
//									.keyboardType(.decimalPad)
//									.multilineTextAlignment(.trailing)
//									.padding(9)
//									.glassEffectStyle()
//							}
							
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
									
									if ingredient.name != editIngredientNameValue.trimmingCharacters(in: .whitespacesAndNewlines) {
										ingredient.sourceIngredientID = nil
									}
									
									ingredient.name = editIngredientNameValue.trimmingCharacters(in: .whitespacesAndNewlines)
									ingredient.color = Color.convertColorToString(selectedColor)
									ingredient.notes = editIngredientNotesValue.trimmingCharacters(in: .whitespacesAndNewlines)
									ingredient.unit = editIngredientUnit
									ingredient.amount = editIngredientUnitValue
									
								}
								editIngredient = nil
								settingsStore.triggerHaptic(&hapticSaved)
								AnalyticsUtils.logButtonTap(screen: .recipeItem, button: .edit)
								saveLastUpdatedDate()
							}
							.disabled(editIngredientNameValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
						}
					}
					.presentationDetents([.large])
					.interactiveDismissDisabled()
					.onAppear {
						editIngredientNameValue = editableIngredient.name
						selectedColor = Color.convertStringToColor(editableIngredient.color)
						editIngredientNotesValue = editableIngredient.notes
						editIngredientUnit = editableIngredient.unit
						editIngredientUnitValue = editableIngredient.amount
					}
					
					//					.onAppear {
					//						editNameValue = recipe.name
					//						selectedColor = Color.convertStringToColor(recipe.color)
					//					}
					
					
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
								AnalyticsUtils.logButtonTap(screen: .recipeItem, button: .edit)
								saveLastUpdatedDate()
							}
						}
					}
					.presentationDetents([.large])
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
							deleteRecipe(recipe)
						}
					} message: {
						Text("This recipe will be removed from your list, but existing meal plans will stay unchanged. This action can’t be undone.")
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
		if storedIngredients.count >= 25 && !ProAccessManager.premiumPurchased { return true } else { return false }
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
		let selectedIDs = Set(recipe.ingredients.map { $0.sourceIngredientID })
		
		return storedIngredients.filter {
			!selectedIDs.contains($0.id)
		}
	}
	
	private func addPickedIngredients(_ pickedIngredients: [Ingredient]) {
		pickedIngredients.forEach { ingredient in
			withAnimation {
				recipe.ingredients.append(RecipeIngredient(
					name: ingredient.name,
					color: ingredient.color,
					unit: ingredient.defaultUnit,
					amount: ingredient.defaultUnit.defaultValue,
					sourceIngredientID: ingredient.id)
				)
			}
		}
		saveLastUpdatedDate()
	}
	
	private func deleteRecipe(_ recipe: Recipe) {
		
		AnalyticsUtils.logButtonTap(screen: .recipeItem, button: .delete)
		settingsStore.triggerHaptic(&hapticDeleted)
		dismiss()
		
		DispatchQueue.main.async {
			
			modelContext.delete(recipe)
			
			do {
				try modelContext.save()
			} catch {
				print("Error removing folder: \(error.localizedDescription)")
			}
			
		}
		
	}
	
	// toast message
	private func showToastCopiedNote() {
		withAnimation {
			toastCopiedNote = true
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			withAnimation {
				toastCopiedNote = false
			}
		}
	}
	
	private func showToastCopiedInstructions() {
		withAnimation {
			toastCopiedInstructions = true
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			withAnimation {
				toastCopiedInstructions = false
			}
		}
	}
	
	// meal plans
	private func attachedMealPlansCount() -> Int {
//		return mealPlans.filter({ $0.recipe.id == recipe.id }).count
		recipe.mealPlans.count
	}
}

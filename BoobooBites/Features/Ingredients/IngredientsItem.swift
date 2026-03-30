//
//  IngredientsItem.swift
//  BoobooBites
//
//  Created by Ryan Rook on 21/03/2026.
//

import SwiftUI
import SwiftData

struct IngredientsItem: View {
	
	// MARK: - properties
	@Environment(SettingsStore.self) private var settingsStore
	
	@Environment(\.modelContext) private var modelContext
	
	@Environment(\.dismiss) var dismiss
	
	@State var ingredient: Ingredient
	
	@State private var editName = false
	@State private var editNameValue = ""
	
	@State private var showNotes = false
	@State private var editNotes = false
	@State private var editNotesValue = ""
	
	@State var selectedColor: Color = .appleRed
	
	let completion: (Ingredient) -> Void
	
	@State private var deleteConfirmationDialog = false
	
	@State private var hapticWarning = false
	@State private var hapticDeleted = false
	@State private var hapticSaved = false
	
	@Query private var recipeIngredients: [RecipeIngredient]
	
	@State private var updateNameMessage = false
	
	@State private var toastCopiedNote = false
	
	// MARK: - body
	var body: some View {
		NavigationStack {
			Form {
				
				Section {
					
					Text(ingredient.name)
						.multilineTextAlignment(.leading)
						.foregroundStyle(.white)
						.bold()
						.frame(maxWidth: .infinity, alignment: .trailing)
						.listRowBackground(Color.convertStringToColor(ingredient.color))
						.listRowSeparator(.hidden, edges: .bottom)
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							Button {
								settingsStore.hideEditTipView()
								editName.toggle()
							} label: {
								Label("Edit", systemImage: "pencil")
							}
							.tint(.appleOrange)
						}
					
					DisclosureGroup(isExpanded: $showNotes) {
						Group {
							if ingredient.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
								
								Text("No notes available")
									.foregroundStyle(.secondary)
								
							} else {
								
								Text(ingredient.notes)
								
							}
						}
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							if !ingredient.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
								
								Button {
									XPasteboard.general.copyText(ingredient.notes)
									settingsStore.triggerHaptic(&hapticSaved)
									AnalyticsUtils.logButtonTap(screen: .ingredientItem, button: .copyNotes)
									showToastCopiedNote()
								} label: {
									Label("Copy", systemImage: "document.on.clipboard")
								}
								.tint(.appleBlue)
								
							}
						}
					} label: {
						Text("Notes")
							.swipeActions(edge: .trailing, allowsFullSwipe: true) {
								Button {
									settingsStore.hideEditTipView()
									editNotes.toggle()
								} label: {
									Label("Edit", systemImage: "pencil")
								}
								.tint(.appleOrange)
							}
					}
					
				} header: {
					if settingsStore.hideEditTip == false {
						Label("Swipe left to edit fields", systemImage: "info.bubble")
							.font(.footnote)
					}
				}
				
				Section {
					
					Picker("Default unit", selection: $ingredient.defaultUnit) {
						ForEach(UnitType.allCases, id: \.self) { unit in
							Text(unit.rawValue.lowercased()).tag(unit)
						}
					}
					.tint(.accent)
					
				}
				
			}
			.navigationTitle("Ingredient")
			.navigationBarTitleDisplayMode(.inline)
			.toastMessage(isActive: $toastCopiedNote, color: .appleBlue, title: "Note Copied", image: "document.on.clipboard")
			.scrollDismissesKeyboard(.interactively)
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
								updateName()
							}
							.disabled(editNameValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
						}
					}
					.alert("Update your recipes?", isPresented: $updateNameMessage, actions: {
						Button("Don't Update Recipes", role: .cancel) { clearExistingRecipeIngredients() }
						Button("Update Name And Color", role: .confirm) { updateExistingRecipeIngredients(updateColor: true) }
						Button("Update Name Only", role: .confirm) { updateExistingRecipeIngredients() }
					}, message: {
						Text("Some recipes use this ingredient, do you want to rename the ingredient in those recipes as well?")
					})
					.presentationDetents([.medium, .large])
					.interactiveDismissDisabled()
					.onAppear {
						editNameValue = ingredient.name
						selectedColor = Color.convertStringToColor(ingredient.color)
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
								updateNotes()
							}
						}
					}
					.presentationDetents([.medium, .large])
					.interactiveDismissDisabled()
					.onAppear { editNotesValue = ingredient.notes }
				}
			}
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Menu {
						Button("Delete Ingredient", systemImage: "trash", role: .destructive) {
							deleteConfirmationDialog.toggle()
							settingsStore.triggerHaptic(&hapticWarning)
						}
					} label: {
						Image(systemName: "ellipsis")
					}
					.confirmationDialog("Delete Ingredient?", isPresented: $deleteConfirmationDialog, titleVisibility: .hidden) {
						Button("Delete Ingredient", role: .destructive) {
							removeIngredient(ingredient)
						}
					} message: {
						Text("This ingredient will be removed from your list, but existing recipes will stay unchanged. This action can’t be undone.")
					}
				}
			}
			.presentationDetents([.large])
			.presentationDragIndicator(.hidden)
			.interactiveDismissDisabled()
			.sensoryFeedback(.warning, trigger: hapticWarning)
			.sensoryFeedback(.success, trigger: [hapticDeleted, hapticSaved])
		}
	}
}

#Preview {
	IngredientsItem(ingredient: Ingredient(name: "Onions", notes: "", defaultUnit: .grams), completion: { _ in })
}

// MARK: - utilities
extension IngredientsItem {
	
	// update
	private func updateName() {
		ingredient.name = editNameValue.trimmingCharacters(in: .whitespacesAndNewlines)
		ingredient.color = Color.convertColorToString(selectedColor)
		
		if recipeIngredientsToUpdate().count > 0 {
			updateNameMessage.toggle()
		} else {
			editName.toggle()
			settingsStore.triggerHaptic(&hapticSaved)
			AnalyticsUtils.logButtonTap(screen: .ingredientItem, button: .edit)
		}
	}
	
	private func recipeIngredientsToUpdate() -> [RecipeIngredient] {
		return recipeIngredients.filter({ $0.sourceIngredientID == ingredient.id })
	}
	
	private func clearExistingRecipeIngredients() {
		recipeIngredientsToUpdate().forEach { recipeIngredient in
			recipeIngredient.sourceIngredientID = nil
		}
		editName.toggle()
		settingsStore.triggerHaptic(&hapticSaved)
		AnalyticsUtils.logButtonTap(screen: .ingredientItem, button: .edit)
	}
	
	private func updateExistingRecipeIngredients(updateColor: Bool = false) {
		recipeIngredientsToUpdate().forEach { recipeIngredient in
			recipeIngredient.name = editNameValue.trimmingCharacters(in: .whitespacesAndNewlines)
			if updateColor { recipeIngredient.color = Color.convertColorToString(selectedColor) }
		}
		editName.toggle()
		settingsStore.triggerHaptic(&hapticSaved)
		AnalyticsUtils.logButtonTap(screen: .ingredientItem, button: .edit)
	}
	
	private func updateNotes() {
		ingredient.notes = editNotesValue.trimmingCharacters(in: .whitespacesAndNewlines)
		editNotes.toggle()
		settingsStore.triggerHaptic(&hapticSaved)
		AnalyticsUtils.logButtonTap(screen: .ingredientItem, button: .edit)
	}
	
	// delete
	private func removeIngredient(_ ingredient: Ingredient) {
		Task {
			try await Task.sleep(
				until: .now + .nanoseconds(33),
				tolerance: .seconds(1),
				clock: .suspending
			)
			deleteIngredient(ingredient)
		}
	}
	
	private func deleteIngredient(_ ingredient: Ingredient) {
		
		dismiss()
		
		DispatchQueue.main.async {
			modelContext.delete(ingredient)
			
			recipeIngredientsToUpdate().forEach { recipeIngredient in
				recipeIngredient.sourceIngredientID = nil
			}
			
			do {
				try modelContext.save()
			} catch {
				print("Error removing folder: \(error.localizedDescription)")
			}
			
			settingsStore.triggerHaptic(&hapticDeleted)
			AnalyticsUtils.logButtonTap(screen: .ingredientItem, button: .delete)
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
}

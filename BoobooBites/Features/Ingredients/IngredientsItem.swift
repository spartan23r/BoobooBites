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
	
	@State private var name: String = String()
	@State private var notes: String = String()
	
	@State var selectedColor: Color = .appleRed
	
	let completion: (Ingredient) -> Void
	
	@State private var deleteConfirmationDialog = false
	
	@State private var hapticWarning = false
	@State private var hapticDeleted = false
	
	// MARK: - body
	var body: some View {
		NavigationStack {
			Form {
				
				Section {
					
					TextField("Name", text: $name)
						.keyboardType(.default)
						.bold()
						.textInputAutocapitalization(.words)
						.textFieldLimiter(text: $name, limit: 32)
					
					TextField("Notes", text: $notes, axis: .vertical)
						.keyboardType(.default)
						.textInputAutocapitalization(.sentences)
				}
				
				Section {
					
					ColorPickerView(selectedColor: $selectedColor)
					
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
			.scrollDismissesKeyboard(.interactively)
			.presentationDetents([.large])
			.interactiveDismissDisabled()
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
						Text("Deleted ingredients will be removed from existing recipes. This action cannot be recovered.")
					}
				}
			}
			.onAppear {
				self.name = ingredient.name
				if let notes = ingredient.notes { self.notes = notes }
				self.selectedColor = Color.convertStringToColor(ingredient.color)
			}
			.onDisappear {
				withAnimation {
					
					if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
						ingredient.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
					}
					
					if let notes = ingredient.notes {
						ingredient.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
					}
					
					ingredient.color = Color.convertColorToString(selectedColor)
					
				}
			}
			.sensoryFeedback(.warning, trigger: hapticWarning)
			.sensoryFeedback(.success, trigger: hapticDeleted)
		}
	}
}

#Preview {
	IngredientsItem(ingredient: Ingredient(name: "Onions"), completion: { _ in })
}

// MARK: - utilities
extension IngredientsItem {
	
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
		
		modelContext.delete(ingredient)
		
		do {
			try modelContext.save()
		} catch {
			print("Error removing folder: \(error.localizedDescription)")
		}
		
		dismiss()
		settingsStore.triggerHaptic(&hapticDeleted)
	}
}

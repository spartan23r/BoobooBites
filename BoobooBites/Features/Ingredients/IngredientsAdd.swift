//
//  IngredientsAdd.swift
//  BoobooBites
//
//  Created by Ryan Rook on 20/03/2026.
//

import SwiftUI
import SwiftData

struct IngredientsAdd: View {
	
	// MARK: - properties
	@Binding var isPresented: Bool
	
	@Environment(SettingsStore.self) private var settingsStore
	
	@Environment(\.modelContext) private var modelContext
	
	@State private var name: String = ""
	@FocusState private var nameIsFocused: Bool
	
	@State private var notes: String = ""
	
	@State private var selectedColor: Color = .appleRed
	
	@State private var selectedDefaultUnit: UnitType = .grams
	
	let completion: (Ingredient) -> Void
	
	@State private var hapticSaved = false
	
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
					
					ColorPickerView(selectedColor: $selectedColor)
					
					Picker("Default unit", selection: $selectedDefaultUnit) {
						ForEach(UnitType.allCases, id: \.self) { unit in
							Text(unit.rawValue.lowercased()).tag(unit)
						}
					}
					.tint(.accent)
					
				}
				
				Section {
					TextField("Notes", text: $notes, axis: .vertical)
						.keyboardType(.default)
						.textInputAutocapitalization(.sentences)
				}
				
			}
			.navigationTitle("New Ingredient")
			.toolbarTitleDisplayMode(.inline)
			.scrollDismissesKeyboard(.interactively)
			.toolbar {
				
				ToolbarItem(placement: .topBarLeading) {
					Button(role: .close) {
						isPresented.toggle()
					}
				}
				
				ToolbarItem(placement: .primaryAction) {
					Button(role: .confirm) {
						saveNewIngredient()
					}
					.disabled(disabledToSave())
				}
				
			}
			.presentationDetents([.large])
			.interactiveDismissDisabled()
			.onAppear { nameIsFocused = true }
			.sensoryFeedback(.success, trigger: hapticSaved)
		}
    }
}

#Preview {
	IngredientsAdd(isPresented: .constant(false), completion: { _ in })
}

// MARK: - utilities
extension IngredientsAdd {
	
	private func disabledToSave() -> Bool {
		if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			return true
		} else {
			return false
		}
	}

	func saveNewIngredient() {
		let ingredient = Ingredient(
			name: name.trimmingCharacters(in: .whitespacesAndNewlines),
			notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
			color: Color.convertColorToString(selectedColor),
			defaultUnit: selectedDefaultUnit
		)

		modelContext.insert(ingredient)

		do {
			try? modelContext.save()
		}

		completion(ingredient)
		isPresented.toggle()
		settingsStore.triggerHaptic(&hapticSaved)
		AnalyticsUtils.logButtonTap(screen: .ingredientAdd, button: .save)
	}
}

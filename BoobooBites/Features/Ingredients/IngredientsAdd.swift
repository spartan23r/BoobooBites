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
	
	var fromRecipeScreen = false
	
	@Environment(SettingsStore.self) private var settingsStore
	
	@Environment(\.modelContext) private var modelContext
	
	@State private var name: String = ""
	@FocusState private var nameIsFocused: Bool
	
	@State private var notes: String = ""
	
	@State private var selectedColor: Color = .appleRed
	
	@State private var selectedDefaultUnit: UnitType = .grams
	@State private var unitValue: Double = 100
	
	let completion: (RecipeIngredient) -> Void
	
	@State private var hapticSaved = false
	
	let decimalFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		return formatter
	}()
	
	// MARK: - body
    var body: some View {
		NavigationStack {
			Form {
				switch fromRecipeScreen {
				case true: ingredientFromRecipeScreenForm
				case false: ingredientForm
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
			notes: fromRecipeScreen ? "" : notes.trimmingCharacters(in: .whitespacesAndNewlines),
			color: Color.convertColorToString(selectedColor),
			defaultUnit: selectedDefaultUnit
		)

		modelContext.insert(ingredient)

		do {
			try? modelContext.save()
		}
		
		if fromRecipeScreen {
			let recipeIngredient = RecipeIngredient(
				name: ingredient.name,
				notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
				color: ingredient.color,
				unit: ingredient.defaultUnit,
				amount: unitValue,
				sourceIngredientID: ingredient.id
			)
			
			completion (recipeIngredient)
		}
		
		isPresented.toggle()
		settingsStore.triggerHaptic(&hapticSaved)
		AnalyticsUtils.logButtonTap(screen: .ingredientAdd, button: .save)
	}
}

// MARK: - views
extension IngredientsAdd {
	
	@ViewBuilder
	private var ingredientForm: some View {
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
			
			Picker("Unit", selection: $selectedDefaultUnit) {
				ForEach(UnitType.allCases, id: \.self) { unit in
					Text(unit.rawValue.lowercased()).tag(unit)
				}
			}
			.tint(.accent)
			
		}
		
	}
	
	@ViewBuilder
	private var ingredientFromRecipeScreenForm: some View {
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
			
			Picker("Unit", selection: $selectedDefaultUnit) {
				ForEach(UnitType.allCases, id: \.self) { unit in
					Text(unit.rawValue.lowercased()).tag(unit)
				}
			}
			.tint(.accent)
			.onChange(of: selectedDefaultUnit) { _,_ in
				withAnimation {
					unitValue = selectedDefaultUnit.defaultValue
				}
			}
			
			TextField("unit value", value: $unitValue, formatter: decimalFormatter)
				.keyboardType(.decimalPad)
				.multilineTextAlignment(.trailing)
			
		}
		
	}
}

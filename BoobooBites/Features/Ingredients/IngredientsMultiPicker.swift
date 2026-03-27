//
//  IngredientsMultiPicker.swift
//  BoobooBites
//
//  Created by Ryan Rook on 23/03/2026.
//

import SwiftUI

struct IngredientsMultiPicker: View {
	
	// MARK: - properties
	@Binding var isPresented: Bool
	
	@Environment(SettingsStore.self) private var settingsStore
	
	var storedIngredients: [Ingredient]
	
	@State private var pickedIngredients: [Ingredient] = []
	
	let completion: ([Ingredient]) -> Void
	
	@State private var hapticPicked = false
	@State private var hapticSaved = false
	
	// MARK: - body
    var body: some View {
		NavigationStack {
			Form {
				ForEach(storedIngredients) { ingredient in
					Button {
						toggleIngredient(ingredient)
					} label: {
						HStack {
							
							Image(systemName: "circle")
								.symbolVariant(pickedIngredients.contains(ingredient) ? .fill : .none)
								.symbolEffect(.bounce, value: pickedIngredients.contains(ingredient))
								.foregroundStyle(Color.convertStringToColor(ingredient.color))
							
							Text(ingredient.name)
							
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						.contentShape(Rectangle())
					}
					.buttonStyle(.plain)
				}
			}
			.navigationTitle("Ingredients")
			.navigationSubtitle("\(storedIngredients.count) stored")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				
				ToolbarItem(placement: .topBarLeading) {
					Button(role: .close) {
						isPresented.toggle()
					}
				}
				
				ToolbarItem(placement: .primaryAction) {
					Button(role: .confirm) {
						isPresented.toggle()
						settingsStore.triggerHaptic(&hapticSaved)
						completion(pickedIngredients)
					}
					.disabled(pickedIngredients.isEmpty)
				}
				
			}
			.presentationDetents([.large])
			.interactiveDismissDisabled()
			.sensoryFeedback(.selection, trigger: hapticPicked)
			.sensoryFeedback(.success, trigger: hapticSaved)
		}
    }
}

#Preview {
	IngredientsMultiPicker(isPresented: .constant(false), storedIngredients: [], completion: { _ in })
}

// MARK: - utilities
extension IngredientsMultiPicker {
	
	private func toggleIngredient(_ ingredient: Ingredient) {
		if pickedIngredients.contains(ingredient) {
			withAnimation {
				pickedIngredients.removeAll(where: { $0 == ingredient })
			}
		} else {
			withAnimation {
				pickedIngredients.append(ingredient)
				settingsStore.triggerHaptic(&hapticPicked)
			}
		}
	}
	
}

// MARK: - views
extension IngredientsMultiPicker {}

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
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) var dismiss
	
	@State var ingredient: Ingredient
	
	@State private var notes: String = ""
	
	@State var selectedColor: Color = .appleRed
	
	let completion: (Ingredient) -> Void
	
	@State private var deleteConfirmationDialog = false
	
	// MARK: - body
	var body: some View {
		NavigationStack {
			Form {
				
				Section {
					
					TextField("Name", text: $ingredient.name)
						.keyboardType(.default)
						.bold()
					
					TextField("Notes", text: $notes, axis: .vertical)
						.onChange(of: notes) { _,newValue in
							ingredient.notes = newValue
						}
					
				}
				
				Section {
					
					ColorPickerView(selectedColor: $selectedColor)
						.onChange(of: selectedColor) { _,newValue in
							ingredient.color = Color.convertColorToString(selectedColor)
						}
					
					Picker("Default unit", selection: $ingredient.defaultUnit) {
						ForEach(UnitType.allCases, id: \.self) { unit in
							Text(unit.rawValue.lowercased()).tag(unit)
						}
					}
					
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
						
						Button(role: .destructive) {
							deleteConfirmationDialog.toggle()
						} label: {
							Label("Delete", systemImage: "trash")
						}
						
					} label: {
						Image(systemName: "ellipsis")
					}
				}
			}
			.confirmationDialog("Delete \(ingredient.name)?", isPresented: $deleteConfirmationDialog, titleVisibility: .visible) {
				Button("Delete", role: .destructive) {
						removeIngredient(ingredient)
				}
			} message: {
				Text("Deleted ingredients will be removed from existing recipes.")
			}
			.onAppear {
				if let notes = ingredient.notes { self.notes = notes }
				self.selectedColor = Color.convertStringToColor(ingredient.color)
			}
			.onDisappear {
				withAnimation {
					ingredient.name = ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines)
					if let notes = ingredient.notes {
						ingredient.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
					}
				}
			}
		}
	}
}

#Preview {
	IngredientsItem(ingredient: Ingredient(name: "Onions"), completion: { _ in })
}

// MARK: - utilities
extension IngredientsItem {
	
	private func removeIngredient(_ ingredient: Ingredient) {
		
		dismiss()
		
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
	}
	
}

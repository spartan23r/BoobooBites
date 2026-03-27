//
//  RecipesAdd.swift
//  BoobooBites
//
//  Created by Ryan Rook on 20/03/2026.
//

import SwiftUI

struct RecipesAdd: View {
	
	// MARK: - properties
	@Binding var isPresented: Bool
	
	@State private var name: String = ""
	@State private var notes: String = ""
	@State private var instructions: String = ""
	
	@State private var prepTime: Int? = nil
	@State private var cookTime: Int? = nil
	@State private var servings: Int? = nil
	
	let numberFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .none
		return formatter
	}()
	
	// MARK: - body
    var body: some View {
		NavigationStack {
			Form {
				
				Section {
					TextField("Name", text: $name)
						.keyboardType(.namePhonePad)
						.bold()
					TextField("Notes", text: $notes, axis: .vertical)
				}
				
				Section {
					TextField("Instructions", text: $instructions, axis: .vertical)
				}
				
				
				Section {
					
					LabeledContent {
						TextField("Minutes", value: $prepTime, formatter: numberFormatter)
							.keyboardType(.numberPad)
							.multilineTextAlignment(.trailing)
					} label: {
						Text("Prep time")
					}
					
					LabeledContent {
						TextField("Minutes", value: $cookTime, formatter: numberFormatter)
							.keyboardType(.numberPad)
							.multilineTextAlignment(.trailing)
					} label: {
						Text("Cook time")
					}
					
					LabeledContent {
						TextField("Persons", value: $servings, formatter: numberFormatter)
							.keyboardType(.numberPad)
							.multilineTextAlignment(.trailing)
					} label: {
						Text("Servings")
					}
					
				}
				
			}
			.navigationTitle("New Recipe")
			.navigationSubtitle("Booboo Bite")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				
				ToolbarItem(placement: .topBarLeading) {
					Button(role: .close) {
						isPresented.toggle()
					}
				}
				
				ToolbarItem(placement: .primaryAction) {
					Button(role: .confirm) {
						
					}
					.disabled(disabledToSave())
				}
				
			}
			.presentationDetents([.large])
			.interactiveDismissDisabled()
		}
    }
}

#Preview {
	RecipesAdd(isPresented: .constant(false))
}

// MARK: - utilities
extension RecipesAdd {
	
	private func disabledToSave() -> Bool {
		if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			return true
		} else {
			return false
		}
	}
	
}

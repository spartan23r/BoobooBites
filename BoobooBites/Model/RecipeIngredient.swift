//
//  RecipeIngredient.swift
//  BoobooBites
//
//  Created by Ryan Rook on 20/03/2026.
//

import SwiftUI
import SwiftData

@Model
final class RecipeIngredient: Identifiable {
	
	var id = UUID()
	var name = String()
	var notes = String()
	var color: String = "apple.red"
	var unit: UnitType = UnitType.grams
	var amount: Double = Double()
	var sourceIngredientID: UUID?
	
	init(id: UUID = UUID(), name: String  = String(), notes: String = String(), color: String = "appleRed", unit: UnitType = .grams, amount: Double, sourceIngredientID: UUID?) {
		self.id = id
		self.name = name
		self.notes = notes
		self.color = color
		self.unit = unit
		self.amount = amount
		self.sourceIngredientID = sourceIngredientID
	}
}

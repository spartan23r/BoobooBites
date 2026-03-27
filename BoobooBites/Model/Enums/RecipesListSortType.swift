//
//  RecipesListSortType.swift
//  BoobooBites
//
//  Created by Ryan Rook on 26/03/2026.
//

import SwiftUI

enum RecipesListSortType: String, CaseIterable, Codable {
	case name, color, preparationTime, ingredientsCount, servingsCount, lastUpdated, createdAt
	
	var description: String {
		switch self {
		case .name:
			"Sort by Name"
		case .color:
			"Sort by Color"
		case .preparationTime:
			"Sort by Preparation Time"
		case .ingredientsCount:
			"Sort by Ingredients Count"
		case .servingsCount:
			"Sort by Servings Count"
		case .lastUpdated:
			"Sort by Last Updated"
		case .createdAt:
			"Sort by Created At"
		}
	}
	
}

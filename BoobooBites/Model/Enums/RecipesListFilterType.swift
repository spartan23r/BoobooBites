//
//  RecipesListFilterType.swift
//  BoobooBites
//
//  Created by Ryan Rook on 26/03/2026.
//

import SwiftUI

enum RecipesListFilterType: String, CaseIterable, Codable {
	case all, favorites
	
	var description: String {
		switch self {
		case .all:
			"All Items"
		case .favorites:
			"Favorites"
		}
	}
	
	var image: String {
		switch self {
		case .all:
			"rectangle.grid.1x3"
		case .favorites:
			"heart"
		}
	}
	
}

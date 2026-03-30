//
//  UnitType.swift
//  BoobooBites
//
//  Created by Ryan Rook on 20/03/2026.
//

import Foundation

enum UnitType: String, CaseIterable, Codable {
	case grams
	case kilograms
	case milliliters
	case liters
	case pieces
	case teaspoons
	case tablespoons
	case cups
	
	var defaultValue: Double {
		switch self {
		case .grams, .milliliters:
			return 100
		case .kilograms, .liters:
			return 2
		case .pieces, .teaspoons, .tablespoons, .cups:
			return 1
		}
	}
}

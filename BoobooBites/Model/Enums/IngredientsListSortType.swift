//
//  IngredientsListSortType.swift
//  BoobooBites
//
//  Created by Ryan Rook on 26/03/2026.
//

import SwiftUI

enum IngredientsListSortType: String, CaseIterable, Codable {
	case name, color/*, defaultUnit*/
	
	var description: String {
		switch self {
		case .name:
			"Sort by Name"
		case .color:
			"Sort by Color"
//		case .defaultUnit:
//			"Sort by Default Unit"
		}
	}
	
}

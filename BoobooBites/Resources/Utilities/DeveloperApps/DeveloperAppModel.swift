//
//  DeveloperAppModel.swift
//  BreakFree
//
//  Created by Ryan Rook on 08/01/2025.
//

import Foundation

struct DeveloperApp: Identifiable, Codable {
	let id: Int
	let text: String
	let subtext: String
	let link: String
	let image: String
}

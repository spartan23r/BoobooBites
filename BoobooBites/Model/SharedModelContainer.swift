//
//  SharedModelContainer.swift
//  BoobooBites
//
//  Created by Ryan Rook on 20/03/2026.
//

import SwiftData

final class SharedModelContainer {
	
	static var container: ModelContainer = {
		let schema = Schema([
			Recipe.self,
			Ingredient.self,
		])
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

		do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}()
}

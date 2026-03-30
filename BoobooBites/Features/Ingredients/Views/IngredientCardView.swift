//
//  IngredientCardView.swift
//  BoobooBites
//
//  Created by Ryan Rook on 28/03/2026.
//

import SwiftUI

enum IngredientNavLinkViewStyle {
	case regular, search
}

struct IngredientCardView: View {
	
	// MARK: - properties
	let ingredient: Ingredient
	var cardStyle: IngredientNavLinkViewStyle = .regular
	
	// MARK: - properties
    var body: some View {
		switch cardStyle {
		case .regular: regularCardView
		case .search: searchCardView
		}
    }
}

#Preview {
	IngredientCardView(ingredient: Ingredient(defaultUnit: .grams))
}

// MARK: - views
extension IngredientCardView {
	
	@ViewBuilder
	private var searchCardView: some View {
		NavigationLink {
			
			IngredientsItem(ingredient: ingredient) { _ in }
			
		} label: {
			
				Text(ingredient.name)
			
		}
	}
	
	@ViewBuilder
	private var regularCardView: some View {
		NavigationLink {
			
			IngredientsItem(ingredient: ingredient) { _ in }
			
		} label: {
			HStack {
				Image(systemName: "circle")
					.symbolVariant(.fill)
					.symbolEffect(.wiggle, value: Color.convertStringToColor(ingredient.color))
					.font(.caption)
					.foregroundStyle(Color.convertStringToColor(ingredient.color).gradient)
				Text(ingredient.name)
					.contentTransition(.numericText())
			}
		}
	}
}

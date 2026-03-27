//
//  MealPlanDayView.swift
//  BoobooBites
//
//  Created by Ryan Rook on 22/03/2026.
//

import SwiftUI

struct MealPlanDayView: View {
	
	// MARK: - properties
	let date: Date
	let isToday: Bool
	let isSelected: Bool
	let mealCount: Int

	// MARK: - body
	var body: some View {
		VStack(spacing: 6) {
			
			Text(date.formatted(.dateTime.day()))
				.font(.body.weight(isToday ? .bold : .regular))
				.frame(width: 36, height: 36)
				.background {
					if isSelected {
						Circle().fill(.accent.opacity(0.4).gradient)
					} else if isToday {
						Circle().stroke(.accent.opacity(0.6).gradient, lineWidth: 1.5)
					}
				}

			mealIndicator
			
		}
		.frame(maxWidth: .infinity, minHeight: 56)
		.contentShape(Rectangle())
	}
}

#Preview {
	MealPlanDayView(date: Date(), isToday: true, isSelected: true, mealCount: 2)
}

// MARK: - views
extension MealPlanDayView {

	@ViewBuilder
	private var mealIndicator: some View {
		if mealCount == 0 {
			Circle()
				.fill(.clear)
				.frame(width: 6, height: 6)
		} else if mealCount <= 3 {
			HStack(spacing: 3) {
				ForEach(0..<mealCount, id: \.self) { _ in
					Circle()
						.fill(.accent.gradient)
						.frame(width: 5, height: 5)
				}
			}
			.frame(height: 6)
		} else {
			Text("\(mealCount)")
				.font(.caption2.weight(.semibold))
				.foregroundStyle(.accent.gradient)
				.frame(minWidth: 16)
		}
	}
}

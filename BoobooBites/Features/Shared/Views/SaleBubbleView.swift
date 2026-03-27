//
//  SaleBubbleView.swift
//  Icebreaker
//
//  Created by Ryan Rook on 29/09/2025.
//

import SwiftUI

#Preview {
	SaleBubbleView()
}

struct SaleBubbleView: View {
	var body: some View {
		Text(ProAccessManager.premiumPurchased ? "Purchased" : "One Time Purchase")
			.foregroundStyle(.white)
			.font(.callout)
			.bold()
			.padding(6)
			.glassEffectStyle(color: ProAccessManager.premiumPurchased ? Color(.sonicPink) : Color(.accent))
			.phaseAnimator([true, false]) { content, phase in
				content
					.scaleEffect(phase ? 1.01 : 1.0)
			} animation: { phase in
					.spring
			}
	}
}

extension Date {
	
	static func isDateInSaleRange() -> Bool {
		let calendar = Calendar.current
		let currentDate = Date()
		
		// Define the start and end dates for the sale
		var startComponents = DateComponents()
		startComponents.year = 2026
		startComponents.month = 1
		startComponents.day = 1
		startComponents.hour = 1
		startComponents.minute = 0
		startComponents.second = 0
		
		var endComponents = DateComponents()
		endComponents.year = 2026
		endComponents.month = 2
		endComponents.day = 1
		endComponents.hour = 23
		endComponents.minute = 59
		endComponents.second = 59
		
		guard let startDate = calendar.date(from: startComponents),
			  let endDate = calendar.date(from: endComponents) else {
			return false // Return false if the dates can't be created
		}
		
		// Check if the current date falls within the range
		return currentDate >= startDate && currentDate <= endDate
	}
}

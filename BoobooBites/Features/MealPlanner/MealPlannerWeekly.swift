//
//  MealPlannerWeekly.swift
//  BoobooBites
//
//  Created by Ryan Rook on 28/03/2026.
//

import SwiftUI
import SwiftData

struct MealPlannerWeekly: View {
	
	// MARK: - properties
	@Environment(SettingsStore.self) private var settingsStore
	
	var mealPlans: [MealPlan]
	
	let calendar: Calendar
	
	@Binding var selectedWeekDate: Date
	
	@Binding var newMealPlan: Bool
	
	@Binding var showPaywall: Bool
	
	// MARK: - body
	var body: some View {
		Form {
			
			Section {
				mealPlanWeekList
			} header: {
				HStack {
					
					Text(selectedWeekTitle)
					
					Spacer()
					
					Text("\(mealPlansForSelectedWeek.count)")
					
				}
				.contentTransition(.numericText())
				.foregroundStyle(.accent)
				.bold()
			}
			
		}
	}
}

#Preview {
	MealPlannerWeekly(mealPlans: [], calendar: AppCalendar.shared, selectedWeekDate: .constant(Date()), newMealPlan: .constant(false), showPaywall: .constant(false))
}

// MARK: - utilities
extension MealPlannerWeekly {
	
	private func reachFreeMealPlansLimit() -> Bool {
		if mealPlans.count >= 14 && !ProAccessManager.premiumPurchased { return true } else { return false }
	}
	
	private func createNewMealPlan() {
		switch reachFreeMealPlansLimit() {
		case true: showPaywall.toggle()
		case false: newMealPlan.toggle()
		}
	}
	
	private var mealPlansForSelectedWeek: [MealPlan] {
		mealPlans
			.filter { $0.date.isInSameWeek(as: selectedWeekDate, using: calendar) }
			.sorted { lhs, rhs in
				let lhsDay = lhs.date.startOfDay
				let rhsDay = rhs.date.startOfDay
				
				if lhsDay == rhsDay {
					return lhs.mealType.sortOrder < rhs.mealType.sortOrder
				}
				
				return lhsDay < rhsDay
			}
	}
	
	private var selectedWeekTitle: String {
		guard let interval = calendar.dateInterval(of: .weekOfYear, for: selectedWeekDate) else {
			return ""
		}
		
		let start = interval.start.formatted(
			.dateTime
				.weekday(.wide)
				.day()
				.month(.abbreviated)
		)
		
		let end = interval.start
			.addingDays(6, using: calendar)
			.formatted(
				.dateTime
					.day()
					.month(.abbreviated)
			)
		
		return "\(start) - \(end)"
	}
}

// MARK: - views
extension MealPlannerWeekly {
	
	@ViewBuilder
	private var mealPlanWeekList: some View {
		if mealPlansForSelectedWeek.isEmpty {
			ContentUnavailableView {
				Label("No meals planned", systemImage: "clock.badge.questionmark")
			} description: {
				Text("Plan your week to stay organized")
			} actions: {
				Button("Plan a meal") {
					createNewMealPlan()
				}
				.buttonStyle(.glassProminent)
			}
		} else {
			ForEach(mealPlansForSelectedWeek, id: \.self) { mealPlan in
				MealPlanCardView(mealPlan: mealPlan, showDate: true)
			}
		}
	}
	
}

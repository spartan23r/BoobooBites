//
//  MealPlannerCalendar.swift
//  BoobooBites
//
//  Created by Ryan Rook on 21/03/2026.
//

import SwiftUI
import SwiftData

struct MealPlannerCalendar: View {
	
	// MARK: - properties
	@Environment(SettingsStore.self) private var settingsStore
	
	var mealPlans: [MealPlan]
	
	let calendar: Calendar
	
	@Binding var currentMonth: Date
	@Binding var selectedDate: Date
	
	@State private var dragOffset: CGFloat = 0
	
	@State private var hapticSwitchingMonth = false
	
	@Binding var newMealPlan: Bool
	
	@Binding var showPaywall: Bool
	
	// MARK: - body
	var body: some View {
		VStack {
			weekdayHeader
			monthGrid
			selectedDateMealsList
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(.offWhite)
		.navigationTitle(currentMonth.formatted(.dateTime.month(.wide).year()))
		.navigationSubtitle("Selected: \(selectedDate.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).year()))")
		.sensoryFeedback(.selection, trigger: hapticSwitchingMonth)
	}
}

#Preview {
	MealPlannerCalendar(mealPlans: [], calendar: Calendar.current, currentMonth: .constant(Date()), selectedDate: .constant(Date()), newMealPlan: .constant(false), showPaywall: .constant(false))
}

// MARK: - utilities
extension MealPlannerCalendar {
	
	private func reachFreeMealPlansLimit() -> Bool {
		if mealPlans.count >= 14 && !ProAccessManager.premiumPurchased { return true } else { return false }
	}
	
	private func createNewMealPlan() {
		switch reachFreeMealPlansLimit() {
		case true: showPaywall.toggle()
		case false: newMealPlan.toggle()
		}
	}
	
	private func mealPlans(for date: Date) -> [MealPlan] {
		let normalizedDate = calendar.startOfDay(for: date)

		return mealPlans.filter {
			calendar.isDate($0.date, inSameDayAs: normalizedDate)
		}.sorted {
			$0.mealType.sortOrder < $1.mealType.sortOrder
		}
	}

	private var weekdaySymbols: [String] {
		let symbols = calendar.shortWeekdaySymbols
		let firstWeekday = calendar.firstWeekday - 1
		return Array(symbols[firstWeekday...] + symbols[..<firstWeekday])
	}

	@ViewBuilder
	private var weekdayHeader: some View {
		let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
		
		LazyVGrid(columns: columns, spacing: 8) {
			ForEach(weekdaySymbols, id: \.self) { day in
				Text(day)
					.font(.caption)
					.foregroundStyle(.accent.gradient)
					.frame(maxWidth: .infinity)
			}
		}
		.background(.offWhite)
	}

	private var calendarDays: [Date?] {
		guard
			let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
			let firstWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
			let lastWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
		else {
			return []
		}
		
		let visibleInterval = DateInterval(start: firstWeekInterval.start, end: lastWeekInterval.end)
		
		var dates: [Date?] = []
		var current = visibleInterval.start
		
		while current < visibleInterval.end {
			if calendar.isDate(current, equalTo: currentMonth, toGranularity: .month) {
				dates.append(current)
			} else {
				dates.append(nil)
			}
			
			current = calendar.date(byAdding: .day, value: 1, to: current)!
		}
		
		return dates
	}

	@ViewBuilder
	private var monthGrid: some View {
		let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
		
		LazyVGrid(columns: columns, spacing: 12) {
			ForEach(Array(calendarDays.enumerated()), id: \.offset) { _, date in
				if let date {
					MealPlanDayView(
						date: date,
						isToday: Calendar.current.isDateInToday(date),
						isSelected: Calendar.current.isDate(selectedDate, inSameDayAs: date),
						mealCount: mealPlans(for: date).count
					)
					.onTapGesture {
						withAnimation {
							selectedDate = date
						}
					}
				} else {
					Color.clear
						.frame(height: 56)
				}
			}
		}
		.offset(x: dragOffset)
		.background(.offWhite)
		.contentShape(Rectangle())
		.gesture(
			DragGesture(minimumDistance: 20)
				.onChanged { value in
					guard abs(value.translation.width) > abs(value.translation.height) else { return }
					dragOffset = value.translation.width
				}
				.onEnded { value in
					let horizontalAmount = value.translation.width
					let verticalAmount = value.translation.height
					
					defer {
						withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
							dragOffset = 0
						}
					}
					
					guard abs(horizontalAmount) > abs(verticalAmount) else { return }
					
					if horizontalAmount < -60 {
						goToNextMonth()
					} else if horizontalAmount > 60 {
						goToPreviousMonth()
					}
				}
		)
	}
	
	private func goToNextMonth() {
		withAnimation(.bouncy) {
			currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
		}
		settingsStore.triggerHaptic(&hapticSwitchingMonth)
	}
	
	private func goToPreviousMonth() {
		withAnimation(.bouncy) {
			currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
		}
		settingsStore.triggerHaptic(&hapticSwitchingMonth)
	}
}

extension MealPlannerCalendar {
	
	@ViewBuilder
	private var selectedDateHeader: some View {
		Text("Selected: \(selectedDate.formatted(.dateTime.weekday(.wide).day().month(.wide)))")
			.font(.subheadline)
			.foregroundStyle(.secondary)
			.padding(.horizontal)
			.frame(maxWidth: .infinity, alignment: .leading)
			.contentTransition(.numericText())
	}
	
	private var selectedDateMealPlans: [MealPlan] {
		mealPlans(for: selectedDate)
	}
	
	@ViewBuilder
	private var selectedDateMealsList: some View {
		List {
			if selectedDateMealPlans.isEmpty {
				ContentUnavailableView {
					Label("No meals planned", systemImage: "clock.badge.questionmark")
				} description: {
					Text("Planned meals will be shown here")
				} actions: {
					Button("Plan a meal") {
						createNewMealPlan()
					}
					.buttonStyle(.glassProminent)
				}
				
			} else {
				ForEach(selectedDateMealPlans, id: \.self) { mealPlan in
					MealPlanCardView(mealPlan: mealPlan)
				}
			}
		}
	}
}

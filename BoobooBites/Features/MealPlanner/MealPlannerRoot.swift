//
//  MealPlannerRoot.swift
//  BoobooBites
//
//  Created by Ryan Rook on 23/03/2026.
//

import SwiftUI
import SwiftData

struct MealPlannerRoot: View {
	
	// MARK: - properties
	@AppStorage("mealPlannerRootScreenType") private var screenType: MealPlannerRootType = .calendar
	
	@Environment(SettingsStore.self) private var settingsStore
	
	@Environment(\.modelContext) private var modelContext
	
	@Query(sort: \MealPlan.date) private var mealPlans: [MealPlan]
	
	private let calendar = Calendar.current
	@State private var currentMonth: Date = Date().startOfMonth(for: .now)
	@State private var selectedDate: Date = Calendar.current.startOfDay(for: .now)
	
	@State private var newMealPlan = false
	
	@State private var showPaywall = false
	
	@State private var deleteConfirmationDialog = false
	
	@State private var hapticWarning = false
	@State private var hapticDeleted = false
	
	// MARK: - body
    var body: some View {
		NavigationStack {
			Group {
				switch screenType {
				case .calendar:
					
					MealPlannerCalendar(
						mealPlans: mealPlans,
						calendar: calendar,
						currentMonth: $currentMonth,
						selectedDate: $selectedDate,
						newMealPlan: $newMealPlan,
						showPaywall: $showPaywall
					)
					
				case .list:
					
					MealPlannerList(
						upcomingMealPlans: upcomingMealPlans(),
						pastMealPlans: pastMealPlans(),
						calendar: calendar
					)
					
				}
			}
			.navigationBarTitleDisplayMode(screenType == .calendar ? .inline : .automatic)
			.toolbar {
				
				if screenType == .calendar {
					ToolbarItemGroup(placement: .topBarLeading) {
						Button("Today") {
							withAnimation {
								goToToday()
							}
						}
						.font(.subheadline)
						.bold()
					}
				}
				
				ToolbarItemGroup(placement: .primaryAction) {
					
					ControlGroup {
						
						Button {
							switchScreenType(to: .calendar)
						} label: {
							Label("Calendar", systemImage: "list.bullet.below.rectangle")
						}
						.tint(screenType == .calendar ? .accent : .primary)
						
						Button {
							switchScreenType(to: .list)
						} label: {
							Label("List", systemImage: "list.dash")
						}
						.tint(screenType == .list ? .accent : .primary)
						
						Divider()
						
						Menu {
							Button(role: .destructive) {
								deleteConfirmationDialog.toggle()
								settingsStore.triggerHaptic(&hapticWarning)
							} label: {
								Label("Delete All Past Meal Plans", systemImage: "trash")
							}
							.disabled(pastMealPlans().isEmpty)
						} label: {
							Text("Remove Meal Plans")
						}
						
					} label: {
						Image(systemName: "ellipsis")
					}
					.controlGroupStyle(.compactMenu)
					.confirmationDialog("Delete All Past Meal Plans?", isPresented: $deleteConfirmationDialog, titleVisibility: .hidden) {
						Button("Delete All Past Meal Plans", role: .destructive) {
							removeAllMealPlans()
						}
					} message: {
						Text("This action cannot be recovered.")
					}
					
					Button {
						createNewMealPlan()
					} label: {
						Image(systemName: "plus")
					}
					
				}
				
			}
			.sheet(isPresented: $newMealPlan) {
				MealPlannerAdd(isPresented: $newMealPlan, selectedDate: $selectedDate) {
					if screenType == .list {
						goToToday()
					}
				}
			}
			.showPaywall(showPaywallMessage: $showPaywall, paywallMessage: .mealplans)
			.sensoryFeedback(.warning, trigger: hapticWarning)
			.sensoryFeedback(.success, trigger: hapticDeleted)
		}
    }
}

#Preview {
    MealPlannerRoot()
}

// MARK: - utilities
extension MealPlannerRoot {
	
	private func reachFreeMealPlansLimit() -> Bool {
		if mealPlans.count >= 14 && !ProAccessManager.premiumPurchased { return true } else { return false }
	}
	
	private func createNewMealPlan() {
		switch reachFreeMealPlansLimit() {
		case true: showPaywall.toggle()
		case false: newMealPlan.toggle()
		}
	}
	
	private func goToToday() {
		currentMonth = Date().startOfMonth(for: .now)
		selectedDate = calendar.startOfDay(for: .now)
	}
	
	private func switchScreenType(to type: MealPlannerRootType) {
		withAnimation {
			switch type {
			case .calendar: screenType = .calendar
			case .list: screenType = .list
			}
			goToToday()
		}
	}
	
	private var today: Date {
		calendar.startOfDay(for: Date())
	}
	
	private func upcomingMealPlans() -> [MealPlan] {
		mealPlans
			.filter { calendar.startOfDay(for: $0.date) >= today }
			.sorted { lhs, rhs in
				let lhsDay = calendar.startOfDay(for: lhs.date)
				let rhsDay = calendar.startOfDay(for: rhs.date)

				if lhsDay == rhsDay {
					return lhs.mealType.sortOrder < rhs.mealType.sortOrder
				}

				return lhsDay < rhsDay
			}
	}

	private func pastMealPlans() -> [MealPlan] {
		mealPlans
			.filter { calendar.startOfDay(for: $0.date) < today }
			.sorted { lhs, rhs in
				let lhsDay = calendar.startOfDay(for: lhs.date)
				let rhsDay = calendar.startOfDay(for: rhs.date)

				if lhsDay == rhsDay {
					return lhs.mealType.sortOrder > rhs.mealType.sortOrder
				}

				return lhsDay > rhsDay
			}
	}
	
	private func removeAllMealPlans() {
		Task {
			try await Task.sleep(
				until: .now + .nanoseconds(33),
				tolerance: .seconds(1),
				clock: .suspending
			)
			deleteAllMealPlans()
		}
	}
	
	private func deleteAllMealPlans() {
		
		pastMealPlans().forEach { mealPlan in
			modelContext.delete(mealPlan)
		}
		
		do {
			try modelContext.save()
		} catch {
			print("Error removing folder: \(error.localizedDescription)")
		}
		
		settingsStore.triggerHaptic(&hapticDeleted)
	}
	
}

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
	@AppStorage("mealPlannerRootScreenType") private var screenType: MealPlannerRootType = .month
	
	@Environment(SettingsStore.self) private var settingsStore
	
	@Environment(\.modelContext) private var modelContext
	
	@Query private var mealPlans: [MealPlan]
	
	let calendar = AppCalendar.shared
	
	private let today = Date().startOfDay
	private let startOfWeek = Date().startOfWeek
	
	@State private var selectedDate: Date = Date().startOfDay
	@State private var currentMonth: Date = Date().startOfMonth
	@State private var selectedWeekDate: Date = Date().startOfWeek
	
	@State private var newMealPlan = false
	
	@State private var showRecipeUsage = false
	
	@State private var showPaywall = false
	
	@State private var deleteConfirmationDialog = false
	
	@State private var hapticWarning = false
	@State private var hapticDeleted = false
	
	@State private var hapticSelection = false
	
	// MARK: - body
    var body: some View {
		NavigationStack {
			Group {
				switch screenType {
				case .month:
					
					MealPlannerCalendar(
						mealPlans: mealPlans,
						calendar: calendar,
						today: today,
						currentMonth: $currentMonth,
						selectedDate: $selectedDate,
						hapticSelection: $hapticSelection,
						newMealPlan: $newMealPlan,
						showPaywall: $showPaywall
					)
					
				case .week:
					
					MealPlannerWeekly(
						mealPlans: mealPlans,
						calendar: calendar,
						selectedWeekDate: $selectedWeekDate,
						newMealPlan: $newMealPlan,
						showPaywall: $showPaywall
					)
					
				case .list:
					
					MealPlannerList(
						upcomingMealPlans: upcomingMealPlans,
						pastMealPlans: pastMealPlans,
						newMealPlan: $newMealPlan,
						showPaywall: $showPaywall
					)
					
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				
				if screenType == .week {
					ToolbarItemGroup(placement: .topBarLeading) {
						Button {
							goToPreviousWeek()
						} label: {
							Image(systemName: "chevron.left")
						}
						Button {
							goToNextWeek()
						} label: {
							Image(systemName: "chevron.right")
						}
					}
				}
				
				if screenType == .month {
					ToolbarItem(placement: .primaryAction) {
						Button("Today") {
							goToToday()
							settingsStore.triggerHaptic(&hapticSelection)
						}
						.font(.subheadline)
						.bold()
					}
					
					ToolbarSpacer(.fixed, placement: .primaryAction)
				}
				
				if screenType == .week {
					ToolbarItem(placement: .primaryAction) {
						Button("This Week") {
							goToThisWeek()
							settingsStore.triggerHaptic(&hapticSelection)
						}
						.font(.subheadline)
						.bold()
					}
					
					ToolbarSpacer(.fixed, placement: .primaryAction)
				}
				
				if screenType == .list {
					ToolbarItem(placement: .primaryAction) {
						Button {
							showRecipeUsage.toggle()
						} label: {
							Image(systemName: "chart.bar")
						}
					}
					
					ToolbarSpacer(.fixed, placement: .primaryAction)
				}
				
				ToolbarItemGroup(placement: .primaryAction) {
					
					ControlGroup {
						
						Button {
							switchScreenType(to: .month)
						} label: {
							Label(MealPlannerRootType.month.title, systemImage: MealPlannerRootType.month.image)
						}
						.tint(screenType == .month ? .accent : .primary)
						
						Button {
							switchScreenType(to: .week)
						} label: {
							Label(MealPlannerRootType.week.title, systemImage: MealPlannerRootType.week.image)
						}
						.tint(screenType == .week ? .accent : .primary)
						
						Button {
							switchScreenType(to: .list)
						} label: {
							Label(MealPlannerRootType.list.title, systemImage: MealPlannerRootType.list.image)
						}
						.tint(screenType == .list ? .accent : .primary)
						
//						Divider()
//						
//						Menu {
//							Button(role: .destructive) {
//								deleteConfirmationDialog.toggle()
//								settingsStore.triggerHaptic(&hapticWarning)
//							} label: {
//								Label("Delete All Past Meal Plans", systemImage: "trash")
//							}
//							.disabled(pastMealPlans.isEmpty)
//						} label: {
//							Text("Remove Meal Plans")
//						}
						
					} label: {
						Image(systemName: screenType.image)
						
					}
					.controlGroupStyle(.menu)
//					.confirmationDialog("Delete All Past Meal Plans?", isPresented: $deleteConfirmationDialog, titleVisibility: .hidden) {
//						Button("Delete All Past Meal Plans", role: .destructive) {
//							removeAllMealPlans()
//						}
//					} message: {
//						Text("All past meal plans will be deleted. This action can’t be undone.")
//					}
					
					Button {
						createNewMealPlan()
					} label: {
						Image(systemName: "plus")
					}
					
				}
				
			}
			.sheet(isPresented: $newMealPlan) {
				MealPlannerAdd(isPresented: $newMealPlan, selectedDate: $selectedDate) {
					if screenType == .list { goToToday() }
					if screenType == .week { goToThisWeekday() }
				}
			}
			.sheet(isPresented: $showRecipeUsage) {
				MealPlannerRecipeUsage(isPresented: $showRecipeUsage)
			}
			.showPaywall(showPaywallMessage: $showPaywall, paywallMessage: .mealplans)
			.sensoryFeedback(.warning, trigger: hapticWarning)
			.sensoryFeedback(.success, trigger: hapticDeleted)
			.sensoryFeedback(.selection, trigger: hapticSelection)
		}
    }
}

#Preview {
    MealPlannerRoot()
}

// MARK: - utilities
extension MealPlannerRoot {
	
	private var reachFreeMealPlansLimit: Bool {
		if mealPlans.count >= 14 && !ProAccessManager.premiumPurchased { return true } else { return false }
	}
	
	private func createNewMealPlan() {
		switch reachFreeMealPlansLimit {
		case true: showPaywall.toggle()
		case false: newMealPlan.toggle()
		}
	}
	
	private func switchScreenType(to type: MealPlannerRootType) {
		withAnimation {
			switch type {
			case .month:
				screenType = .month
				goToToday()
			case .week:
				screenType = .week
				goToThisWeek()
			case .list:
				screenType = .list
				goToToday()
			}
		}
	}
	
	private func goToToday() {
		withAnimation {
			currentMonth = today.startOfMonth
			selectedDate = today
		}
	}
	
	// weekly
	private func goToThisWeek() {
		withAnimation {
			selectedWeekDate = startOfWeek
			selectedDate = startOfWeek
		}
	}
	
	private func goToThisWeekday() {
		withAnimation {
			selectedWeekDate = selectedDate.startOfWeek
		}
	}
	
	private func goToNextWeek() {
		withAnimation {
			let startOfWeek = selectedWeekDate.addingWeeks(1, using: calendar).startOfWeek
			selectedWeekDate = startOfWeek
			selectedDate = startOfWeek
		}
		settingsStore.triggerHaptic(&hapticSelection)
	}
	
	private func goToPreviousWeek() {
		withAnimation {
			let startOfWeek = selectedWeekDate.addingWeeks(-1, using: calendar).startOfWeek
			selectedWeekDate = startOfWeek
			selectedDate = startOfWeek
		}
		settingsStore.triggerHaptic(&hapticSelection)
	}
	
	// list
	private var upcomingMealPlans: [MealPlan] {
		mealPlans
			.filter { $0.date.startOfDay >= today }
			.sorted { lhs, rhs in
				let lhsDay = lhs.date.startOfDay
				let rhsDay = rhs.date.startOfDay

				if lhsDay == rhsDay {
					return lhs.mealType.sortOrder < rhs.mealType.sortOrder
				}

				return lhsDay < rhsDay
			}
	}

	private var pastMealPlans: [MealPlan] {
		mealPlans
			.filter { $0.date.startOfDay < today }
			.sorted { lhs, rhs in
				let lhsDay = lhs.date.startOfDay
				let rhsDay = rhs.date.startOfDay

				if lhsDay == rhsDay {
					return lhs.mealType.sortOrder > rhs.mealType.sortOrder
				}

				return lhsDay > rhsDay
			}
	}
}

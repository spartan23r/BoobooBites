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
	
	@State private var showPaywall = false
	
	@State private var deleteConfirmationDialog = false
	
	@State private var hapticWarning = false
	@State private var hapticDeleted = false
	
	@State private var hapticSelection = false
	
	// MARK: - body
    var body: some View {
		NavigationStack {
			Group {
				switch settingsStore.mealPlannerRootScreenType {
				case .month:
					
					MealPlannerCalendar(
						mealPlans: mealPlans,
						calendar: calendar,
						today: today,
						currentMonth: $currentMonth,
						selectedDate: $selectedDate,
						hapticSelection: $hapticSelection,
						newMealPlan: $newMealPlan,
						showPaywall: $showPaywall,
						deleteMealPlan: { mealPlan in
							deleteMealPlan(mealPlan)
						}
					)
					
				case .week:
					
					MealPlannerWeekly(
						mealPlans: mealPlans,
						calendar: calendar,
						selectedWeekDate: $selectedWeekDate,
						newMealPlan: $newMealPlan,
						showPaywall: $showPaywall,
						deleteMealPlan: { mealPlan in
							deleteMealPlan(mealPlan)
						}
					)
					
				case .list:
					
					MealPlannerList(
						upcomingMealPlans: upcomingMealPlans,
						pastMealPlans: pastMealPlans,
						newMealPlan: $newMealPlan,
						showPaywall: $showPaywall,
						deleteMealPlan: { mealPlan in
							deleteMealPlan(mealPlan)
						}
					)
					
				}
			}
			.toolbarTitleDisplayMode(.inline)
			.toolbar {
				
				if settingsStore.mealPlannerRootScreenType == .week {
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
				
				if settingsStore.mealPlannerRootScreenType == .month {
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
				
				if settingsStore.mealPlannerRootScreenType == .week {
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
				
				ToolbarItemGroup(placement: .primaryAction) {
					
//					Menu {
//						
//						Button("Delete All Past Meal Plans", systemImage: "trash", role: .destructive) {
//							deleteConfirmationDialog.toggle()
//							settingsStore.triggerHaptic(&hapticWarning)
//						}
//						.disabled(pastMealPlans.isEmpty)
//						
//					} label: {
//						Image(systemName: "ellipsis")
//					}
//					.confirmationDialog("Delete All Past Meal Plans?", isPresented: $deleteConfirmationDialog, titleVisibility: .hidden) {
//						if pastMealPlans.isEmpty {
//							Button(role: .close) {}
//						} else {
//							Button("Delete All Past Meal Plans", role: .destructive) {
//								deleteAllMealPlans()
//							}
//						}
//					} message: {
//						Text("All past meal plans will be deleted. This action can’t be undone.")
//					}
					
					ControlGroup {
						
						Button {
							switchScreenType(to: .month)
						} label: {
							Label(MealPlannerRootType.month.title, systemImage: MealPlannerRootType.month.image)
						}
						.tint(settingsStore.mealPlannerRootScreenType == .month ? .accent : .primary)
						
						Button {
							switchScreenType(to: .week)
						} label: {
							Label(MealPlannerRootType.week.title, systemImage: MealPlannerRootType.week.image)
						}
						.tint(settingsStore.mealPlannerRootScreenType == .week ? .accent : .primary)
						
						Button {
							switchScreenType(to: .list)
						} label: {
							Label(MealPlannerRootType.list.title, systemImage: MealPlannerRootType.list.image)
						}
						.tint(settingsStore.mealPlannerRootScreenType == .list ? .accent : .primary)
						
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
						Image(systemName: settingsStore.mealPlannerRootScreenType.image)
						
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
					if settingsStore.mealPlannerRootScreenType == .list { goToToday() }
					if settingsStore.mealPlannerRootScreenType == .week { goToThisWeekday() }
				}
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
				settingsStore.mealPlannerRootScreenType = .month
				goToToday()
			case .week:
				settingsStore.mealPlannerRootScreenType = .week
				goToThisWeek()
			case .list:
				settingsStore.mealPlannerRootScreenType = .list
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
	
	// delete
	private func deleteMealPlan(_ mealPlan: MealPlan) {
		
		AnalyticsUtils.logButtonTap(screen: .mealPlanItem, button: .delete)
		settingsStore.triggerHaptic(&hapticDeleted)
		
		DispatchQueue.main.async {
			
			modelContext.delete(mealPlan)
			
			do {
				try modelContext.save()
			} catch {
				print("Error removing meal plan: \(error.localizedDescription)")
			}
			
		}
		
	}
//	private func deleteAllMealPlans() {
//		
//		settingsStore.triggerHaptic(&hapticDeleted)
//		
//		DispatchQueue.main.async {
//			pastMealPlans.forEach { mealPlan in
//				modelContext.delete(mealPlan)
//			}
//			
//			do {
//				try modelContext.save()
//			} catch {
//				print("Error removing meal plans: \(error.localizedDescription)")
//			}
//			
//		}
//		
//	}
}

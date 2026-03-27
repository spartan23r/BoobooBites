//
//  MealPlannerRoot.swift
//  BoobooBites
//
//  Created by Ryan Rook on 23/03/2026.
//

import SwiftUI
import SwiftData

enum MealPlannerScreenType {
	case calendar, list
}

struct MealPlannerRoot: View {
	
	// MARK: - properties
	@State private var screenType: MealPlannerScreenType = .calendar
	
	@Environment(\.modelContext) private var modelContext
	
	@Query(sort: \MealPlan.date) private var mealPlans: [MealPlan]
	
	private let calendar = Calendar.current
	@State private var currentMonth: Date = Date().startOfMonth(for: .now)
	@State private var selectedDate: Date = Calendar.current.startOfDay(for: .now)
	
	@State private var createNewMealPlan = false
	
	@State private var deletePastMealPlansConfirmationDialog = false
	
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
						createNewMealPlan: $createNewMealPlan
					)
					
				case .list:
					
					MealPlannerList(
						upcomingMealPlans: upcomingMealPlans(),
						pastMealPlans: pastMealPlans(),
						calendar: calendar
					)
					
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				
				if screenType == .calendar {
					ToolbarItemGroup(placement: .topBarLeading) {
						Button("Today") {
							withAnimation {
								goToToday()
							}
						}
					}
				}
				
				ToolbarItemGroup(placement: .primaryAction) {
					
					Button {
						if screenType == .list {
							goToToday()
						}
						createNewMealPlan.toggle()
					} label: {
						Image(systemName: "plus")
					}
					
					ControlGroup {
						
						Button {
							withAnimation {
								screenType = .calendar
								selectedDate = calendar.startOfDay(for: .now)
							}
						} label: {
							Label("Calendar", systemImage: "list.bullet.below.rectangle")
						}
						
						Button {
							withAnimation {
								screenType = .list
							}
						} label: {
							Label("List", systemImage: "list.dash")
						}
						
						Divider()
						
						Button(role: .destructive) {
							deletePastMealPlansConfirmationDialog.toggle()
						} label: {
							Label("Delete All Past Plans", systemImage: "trash")
						}
						.disabled(pastMealPlans().isEmpty)
						
					} label: {
						Image(systemName: "ellipsis")
					}
					.controlGroupStyle(.menu)
					.confirmationDialog("Delete All Past Meal Plans?", isPresented: $deletePastMealPlansConfirmationDialog, titleVisibility: .visible) {
						Button("Delete All", role: .destructive) {
							removeAllMealPlans()
						}
					} message: {
						Text("This action cannot be recovered.")
					}
					
				}
				
			}
			.sheet(isPresented: $createNewMealPlan) {
				MealPlannerAdd(isPresented: $createNewMealPlan, selectedDate: selectedDate)
			}
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
	
	private func goToToday() {
		currentMonth = Date().startOfMonth(for: .now)
		selectedDate = calendar.startOfDay(for: .now)
	}
	
	private func switchScreenType() {
		withAnimation {
			switch screenType {
			case .calendar: screenType = .list
			case .list:
				goToToday()
				screenType = .calendar
			}
		}
	}
	
	private func upcomingMealPlans() -> [MealPlan] {
		mealPlans
			.filter({ $0.date > Date() })
	}
	
	private func pastMealPlans() -> [MealPlan] {
		mealPlans
			.filter({ $0.date < Date() })
			.sorted(by: { $0.date > $1.date })
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
		
		hapticDeleted.toggle()
	}
	
}

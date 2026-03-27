//
//  MealPlannerList.swift
//  BoobooBites
//
//  Created by Ryan Rook on 22/03/2026.
//

import SwiftUI
import SwiftData

struct MealPlannerList: View {
	
	// MARK: - properties
	var upcomingMealPlans: [MealPlan]
	var pastMealPlans: [MealPlan]
	
//	@Binding var isPresented: Bool
	let calendar: Calendar
//	private let calendar = Calendar.current
	
//	@Environment(\.modelContext) private var modelContext
	
//	@Query(sort: \MealPlan.date) private var mealPlans: [MealPlan]
	
	@State private var expandUpcomingSection = true
	@State private var expandPastSection = false
	
	// MARK: - body
	var body: some View {
//		NavigationStack {
			Form {
				
				Section {
					if expandUpcomingSection {
						if upcomingMealPlans.isEmpty {
							Text("No upcoming plans")
								.foregroundStyle(.secondary)
						} else {
							ForEach(upcomingMealPlans) { mealPlan in
								MealPlanCardView(mealPlan: mealPlan, showDate: true)
							}
						}
					}
				} header: {
					Button {
						withAnimation {
							expandUpcomingSection.toggle()
						}
					} label: {
						HStack {
							
							Text("Upcoming")
							
							Spacer()
							
							if !expandUpcomingSection {
								Text("\(upcomingMealPlans.count)")
							}
							
							Image(systemName: "chevron.right")
								.font(.caption)
								.rotationEffect(.degrees(expandUpcomingSection ? 90 : 0))
							
						}
						.bold()
					}
				}
				
				Section {
					if expandPastSection {
						if pastMealPlans.isEmpty {
							Text("Your completed plans will be shown here")
								.foregroundStyle(.secondary)
						} else {
							ForEach(pastMealPlans) { mealPlan in
								MealPlanCardView(mealPlan: mealPlan, showDate: true)
							}
						}
					}
				} header: {
					Button {
						withAnimation {
							expandPastSection.toggle()
						}
					} label: {
						HStack {
							
							Text("Past")
							
							Spacer()
							
							if !expandPastSection {
								Text("\(pastMealPlans.count)")
							}
							
							Image(systemName: "chevron.right")
								.font(.caption)
								.rotationEffect(.degrees(expandPastSection ? 90 : 0))
							
						}
						.bold()
					}
				}
				
			}
			.navigationTitle("Meal Planner")
			.navigationSubtitle("\(upcomingMealPlans.count) upcoming")
//			.toolbar {
//				
//				ToolbarItem(placement: .topBarLeading) {
//					Button(role: .close) {
//						isPresented.toggle()
//					}
//				}
//				
//			}
//			.presentationDetents([.large])
//			.interactiveDismissDisabled()
//		}
	}
}

#Preview {
	MealPlannerList(upcomingMealPlans: [], pastMealPlans: [], calendar: Calendar.current)
}

// MARK: - utilities
extension MealPlannerList {}

// MARK: - views
extension MealPlannerList {}

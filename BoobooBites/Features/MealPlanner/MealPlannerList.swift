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
	@State private var expandUpcomingSection = true
	var upcomingMealPlans: [MealPlan]
	
	@State private var expandPastSection = false
	var pastMealPlans: [MealPlan]
	
	@Binding var newMealPlan: Bool
	
	@Binding var showPaywall: Bool
	
	// MARK: - body
	var body: some View {
		Form {
			
			Section {
				if expandUpcomingSection {
					if upcomingMealPlans.isEmpty {
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
	}
}

#Preview {
	MealPlannerList(upcomingMealPlans: [], pastMealPlans: [], newMealPlan: .constant(false), showPaywall: .constant(false))
}

// MARK: - utilities
extension MealPlannerList {
	
	private func reachFreeMealPlansLimit() -> Bool {
		if (upcomingMealPlans + pastMealPlans).count >= 14 && !ProAccessManager.premiumPurchased { return true } else { return false }
	}
	
	private func createNewMealPlan() {
		switch reachFreeMealPlansLimit() {
		case true: showPaywall.toggle()
		case false: newMealPlan.toggle()
		}
	}
}

// MARK: - views
extension MealPlannerList {}

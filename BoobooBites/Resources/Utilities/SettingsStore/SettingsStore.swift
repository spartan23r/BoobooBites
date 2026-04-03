//
//  SettingsStore.swift
//  BoobooBites
//
//  Created by Ryan Rook on 23/03/2026.
//

import SwiftUI
import Observation

@Observable
final class SettingsStore {
	
	// onboarding
	@ObservationIgnored
	@AppStorage("onboardingState") private var persistedOnboardingState: OnboardingState = .welcome

	var onboardingState: OnboardingState = .welcome {
		didSet {
			persistedOnboardingState = onboardingState
		}
	}
	
	// haptics
	@ObservationIgnored
	@AppStorage("enableHaptics") private var persistedEnableHaptics: Bool = true

	var enableHaptics: Bool = true {
		didSet {
			persistedEnableHaptics = enableHaptics
		}
	}
	
	// default meal plan type
	@ObservationIgnored
	@AppStorage("defaultMealPlanType") private var persistedDefaultMealPlanType: MealType = .dinner

	var defaultMealPlanType: MealType = .dinner {
		didSet {
			persistedDefaultMealPlanType = defaultMealPlanType
		}
	}
	
	// meal planner screen type
	@ObservationIgnored
	@AppStorage("mealPlannerRootScreenType") private var persistedMealPlannerRootScreenType: MealPlannerRootType = .month
	
	var mealPlannerRootScreenType: MealPlannerRootType = .month {
		didSet {
			persistedMealPlannerRootScreenType = mealPlannerRootScreenType
		}
	}
	
	// recipe list sort type
	@ObservationIgnored
	@AppStorage("recipesListSortType") private var persistedRecipesListSortType: RecipesListSortType = .name

	var recipesListSortType: RecipesListSortType = .name {
		didSet {
			persistedRecipesListSortType = recipesListSortType
		}
	}
	
	// recipe list filter type
	@ObservationIgnored
	@AppStorage("recipesListFilterType") private var persistedRecipesListFilterType: RecipesListFilterType = .all

	var recipesListFilterType: RecipesListFilterType = .all {
		didSet {
			persistedRecipesListFilterType = recipesListFilterType
		}
	}
	
	// ingredients list sort type
	@ObservationIgnored
	@AppStorage("ingredientsListSortType") private var persistedIngredientsListSortType: IngredientsListSortType = .name

	var ingredientsListSortType: IngredientsListSortType = .name {
		didSet {
			persistedIngredientsListSortType = ingredientsListSortType
		}
	}
	
	// tooltips
	@ObservationIgnored
	@AppStorage("hideSwipeMonthsTip") private var persistedHideSwipeMonthsTip: Bool = false
	
	var hideSwipeMonthsTip: Bool = false {
		didSet {
			persistedHideSwipeMonthsTip = hideSwipeMonthsTip
		}
	}

	// init
	init() {
		onboardingState = persistedOnboardingState
		
		enableHaptics = persistedEnableHaptics
		
		mealPlannerRootScreenType = persistedMealPlannerRootScreenType
		defaultMealPlanType = persistedDefaultMealPlanType
		
		recipesListSortType = persistedRecipesListSortType
		recipesListFilterType = persistedRecipesListFilterType
		
		ingredientsListSortType = persistedIngredientsListSortType
		
		hideSwipeMonthsTip = persistedHideSwipeMonthsTip
	}
}

// MARK: - onboarding
extension SettingsStore {
	
	func resetOnboarding() {
		onboardingState = .welcome
		hideSwipeMonthsTip = false
	}
	
	func switchOnboardingNextState(finishedOnboardingHaptic: inout Bool) {
		withAnimation {
			switch onboardingState {
			case .welcome: onboardingState = .page1
			case .page1: onboardingState = .page2
			case .page2: onboardingState = .page3
			case .page3, .finished: onboardingState = .finished
			}
		}
		
		if onboardingState == .finished {
			triggerHaptic(&finishedOnboardingHaptic)
		}
	}
	
	func switchOnboardingPreviousState() {
		withAnimation {
			switch onboardingState {
			case .welcome: return
			case .page1: onboardingState = .welcome
			case .page2: onboardingState = .page1
			case .page3, .finished: onboardingState = .page2
			}
		}
	}
}

// MARK: - haptics
extension SettingsStore {
	
	func triggerHaptic(_ trigger: inout Bool) {
		if enableHaptics {
			trigger.toggle()
		}
	}
	
}

// MARK: - recipes list
extension SettingsStore {
	
	func setListSorting(to type: RecipesListSortType) {
		withAnimation {
			recipesListSortType = type
		}
	}
	
	func setListFilter(to type: RecipesListFilterType) {
		withAnimation {
			recipesListFilterType = type
		}
	}
	
	func resetListFilter() {
		withAnimation {
			recipesListFilterType = .all
		}
	}
}

// MARK: - meal planner root
extension SettingsStore {
	
	func setRootScreenTo(_ screenType: MealPlannerRootType) {
		withAnimation {
			mealPlannerRootScreenType = screenType
		}
	}
	
}

// MARK: - tooltips
extension SettingsStore {
	
	func hideSwipeMonthsTipView() {
		if hideSwipeMonthsTip == false {
			withAnimation {
				hideSwipeMonthsTip = true
			}
		}
	}
	
}

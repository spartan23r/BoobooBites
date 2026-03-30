//
//  BoobooBitesApp.swift
//  BoobooBites
//
//  Created by Ryan Rook on 20/03/2026.
//

import SwiftUI
import SwiftData

@main
struct BoobooBitesApp: App {
	
	// MARK: - properties
	@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
	@Environment(\.scenePhase) private var scenePhase
	@State private var settingsStore = SettingsStore()
	@StateObject private var purchaseStore = PurchaseStore()
	
	@State private var searchableText: String = ""
	@State private var selectedSearchListType: SearchListType = .recipes
	
	// MARK: - body
	var body: some Scene {
		WindowGroup {
			Group {
				switch settingsStore.onboardingState {
				case .finished: rootTabView
				default: onboardingView
				}
			}
			.environment(settingsStore)
			.environmentObject(purchaseStore)
			.task(id: scenePhase) {
				if scenePhase == .active {
					await purchaseStore.fetchActiveTransactions()
				}
//				if scenePhase == .background {
//					NotificationManager.checkNotificationAuthorizationStatus()
//					WidgetCenterManager.reloadAllTimelines()
//				}
			}
		}
		.modelContainer(SharedModelContainer.container)
	}
}

extension BoobooBitesApp {
	
	@ViewBuilder
	private var onboardingView: some View {
		Onboarding()
	}
	
	@ViewBuilder
	private var rootTabView: some View {
		TabView {
			
			Tab {
				RecipesList()
			} label: {
				Image(systemName: "fork.knife")
					.symbolVariant(.fill)
			}
			
			Tab {
				MealPlannerRoot()
			} label: {
				Image(systemName: "calendar")
					.symbolVariant(.fill)
			}
			
			Tab(role: .search) {
				SearchList(selectedSearchListType: $selectedSearchListType, searchableText: $searchableText)
					.searchable(text: $searchableText, prompt: selectedSearchListType == .recipes ? "Search on name, notes, instructions, and ingredients" : "Search on name, and notes")
			}
		}
	}
	
}

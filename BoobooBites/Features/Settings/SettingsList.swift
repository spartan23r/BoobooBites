//
//  SettingsList.swift
//  BoobooBites
//
//  Created by Ryan Rook on 23/03/2026.
//

import SwiftUI

struct SettingsList: View {
	
	// MARK: - properties
	@Binding var isPresented: Bool
	
	@Environment(SettingsStore.self) private var settingsStore
	
	let developerAppsData = Bundle.main.decode([DeveloperApp].self, from: "AppsBySpartan23R.json")
	
	// MARK: - body
    var body: some View {
		NavigationStack {
			List {
				
				Section {
					GetPlusButtonView()
				}
				
				generalSection
				feedbackSection
				otherAppsSection
			}
			.navigationTitle("Settings")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button(role: .close) {
						isPresented.toggle()
					}
				}
			}
			.presentationDetents([.large])
			.presentationDragIndicator(.visible)
		}
    }
}

#Preview {
	SettingsList(isPresented: .constant(false))
}

// MARK: - utilities
extension SettingsList {}

// MARK: - views
extension SettingsList {
	
	@ViewBuilder
	private var generalSection: some View {
		Section {
			enableHapticsView
		} header: {
			Text("General")
		}
	}
	
	@ViewBuilder
	private var enableHapticsView: some View {
		Toggle(isOn: Binding(
			get: { settingsStore.enableHaptics },
			set: { settingsStore.enableHaptics = $0 }
		), label: {
			Label {
				Text("Enable Haptics")
					.font(.subheadline)
			} icon: {
				Image(systemName: "iphone.radiowaves.left.and.right")
					.symbolEffect(.wiggle, value: settingsStore.enableHaptics)
					.listRoundedIconStyle(bgc: .sonicBlue, filledIconStyle: true)
					.font(.subheadline)
			}
		})
	}
	
	@ViewBuilder
	private var defaultMealPlanTypeView: some View {
		Picker(selection: Binding(
			get: { settingsStore.defaultMealPlanType },
			set: { settingsStore.defaultMealPlanType = $0 }
		), content: {
			ForEach(MealType.allCases, id: \.self) { type in
				Text(type.rawValue.capitalized).tag(type)
			}
		}, label: {
			Label {
				VStack(alignment: .leading) {
					Text("Meal Plan Type")
						.font(.subheadline)
					Text("Default")
						.font(.caption)
				}
			} icon: {
				settingsStore.defaultMealPlanType.image
					.foregroundStyle(.white)
					.symbolEffect(.rotate, value: settingsStore.defaultMealPlanType)
					.listRoundedIconStyle(bgc: settingsStore.defaultMealPlanType.color, filledIconStyle: true)
					.font(.subheadline)
			}
		})
		.tint(.accent)
		.animation(.smooth, value: settingsStore.defaultMealPlanType)
	}
	
	@ViewBuilder
	private var resetOnboardingView: some View {
		Button {
			isPresented.toggle()
			withAnimation {
				settingsStore.resetOnboarding()
			}
		} label: {
			LabeledContent {
				Image(systemName: "chevron.right")
					.foregroundStyle(.accent)
			} label: {
				Label {
					Text("Show Onboarding")
						.font(.subheadline)
				} icon: {
					Image(systemName: "fork.knife")
						.listRoundedIconStyle(bgc: .accentColor, filledIconStyle: true)
						.font(.subheadline)
				}
			}
		}.foregroundStyle(.primary)
	}
	
	@ViewBuilder
	private var feedbackSection: some View {
		Section {
			rateMeView
			feedbackView
			resetOnboardingView
		} header: {
			Text("Support")
		}
	}
	
	@ViewBuilder
	private var feedbackView: some View {
		Link(destination: URL(string: "mailto:sparky@spartan23r.com")!) {
			LabeledContent {
				Image(systemName: "chevron.right")
					.foregroundStyle(.accent)
			} label: {
				Label {
					Text("Feedback")
						.font(.subheadline)
				} icon: {
					Image(systemName: "questionmark.bubble")
						.listRoundedIconStyle(bgc: .sonicGreen, filledIconStyle: true)
						.font(.subheadline)
				}
			}
		}.foregroundStyle(.primary)
	}
	

	@ViewBuilder
	private var rateMeView: some View {
		Button {
			ReviewStore.requestReviewManually()
		} label: {
			LabeledContent {
				Image(systemName: "chevron.right")
					.foregroundStyle(.accent)
			} label: {
				Label {
					Text("Rate Booboo Bites")
						.font(.subheadline)
				} icon: {
					Image(systemName: "heart")
						.listRoundedIconStyle(bgc: .applePink, filledIconStyle: true)
						.font(.subheadline)
				}
			}
		}.foregroundStyle(.primary)
	}
	
	@ViewBuilder
	private var otherAppsSection: some View {
		Section {
			ForEach(developerAppsData) { app in
				otherAppView(app)
			}
		} header: {
			Text("My Other Apps")
		} footer: {
			appVersionNumberView
				.frame(maxWidth: .infinity, alignment: .center)
		}
	}
	
	@ViewBuilder
	private func otherAppView(_ app: DeveloperApp) -> some View {
		Link(destination: .init(string: "https://\(app.link)")!) {
			HStack(alignment: .center, spacing: 9) {
				Image(app.image)
					.resizable()
					.scaledToFit()
					.corneredRadius(radius: 12)
					.listRoundedIconStyle()
					.shadow(radius: 0.2)
				VStack(alignment: .leading) {
					Text(app.text)
						.font(.subheadline)
					Text(app.subtext)
						.font(.caption)
				}
				Spacer()
				Image(systemName: "chevron.right")
					.symbolRenderingMode(.monochrome)
					.foregroundStyle(Color.accentColor)
					.font(.callout)
			}
		}
		.tint(.primary)
	}
	
	@ViewBuilder
	private var appVersionNumberView: Text {
		Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown version")
		
	}
}

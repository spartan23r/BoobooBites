//
//  Onboarding.swift
//  BoobooBites
//
//  Created by Ryan Rook on 23/03/2026.
//

import SwiftUI

struct Onboarding: View {
	
	// MARK: - properties
	@Environment(SettingsStore.self) private var settingsStore
	
	@State private var showWelcomeAnimations = false
	@State private var finishedOnboardingHaptic = false
	
	// MARK: - body
	var body: some View {
		NavigationStack {
			GeometryReader { proxy in
				VStack(spacing: 48) {
					
					VStack {
						Text(settingsStore.onboardingState.title)
							.font(settingsStore.onboardingState == .welcome ? .largeTitle : .title2)
							.bold()
							.contentTransition(.numericText())
						Text(settingsStore.onboardingState.description)
							.font(.headline)
							.contentTransition(.numericText())
					}
					.multilineTextAlignment(.center)
					.foregroundStyle(.white)
					.horizontalPadding()
					.transition(.push(from: .trailing))
					
					if showWelcomeAnimations {
						
						settingsStore.onboardingState.image
							.resizable()
							.scaledToFit()
							.frame(maxWidth: proxy.size.width * (settingsStore.onboardingState == .welcome ? 1.0 : 0.65), alignment: .center)
							.imageGlassEffectStyleModifier(isOn: settingsStore.onboardingState != .welcome)
							.transition(.scale)
							.animation(.bouncy, value: settingsStore.onboardingState)
							.phaseAnimator([true, false]) { content, phase in
								content
									.scaleEffect(phase ? (settingsStore.onboardingState == .welcome ? 1.03 : 1.01) : 1.0)
							} animation: { phase in
									.spring
							}
						
					}
					
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
				.background(.accent)
				.safeAreaInset(edge: .bottom) {
					if showWelcomeAnimations {
					
						Grid(horizontalSpacing: 24) {
							GridRow {
								
								if settingsStore.onboardingState != .welcome {
									
									Button("Previous") {
										settingsStore.switchOnboardingPreviousState()
									}
									.buttonStyle(.glass)
									.transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
									
								}
								
								Button(settingsStore.onboardingState.buttonTitle) {
									settingsStore.switchOnboardingNextState(finishedOnboardingHaptic: &finishedOnboardingHaptic)
								}
								.buttonStyle(.glass)
								
							}
						}
						.transition(.push(from: .bottom).combined(with: .scale))
						
					}
				}
				.sensoryFeedback(.success, trigger: finishedOnboardingHaptic)
				.onAppear {
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
						withAnimation {
							showWelcomeAnimations = true
						}
					}
				}
			}
		}
	}
}

#Preview {
	Onboarding()
		.environment(SettingsStore())
}

// MARK: - utilities
extension Onboarding {}

// MARK: - views
extension Onboarding {}

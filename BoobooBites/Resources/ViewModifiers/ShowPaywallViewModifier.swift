//
//  PaywallViewModifier.swift
//  BoobooBites
//
//  Created by Ryan Rook on 26/03/2026.
//

import SwiftUI

private struct PaywallViewModifier: ViewModifier {
	
	// MARK: - properties
	@Binding var showPaywallMessage: Bool
	@Binding var showPaywall: Bool
	
	// MARK: - body
	func body(content: Content) -> some View {
		content
			.sheet(isPresented: $showPaywall) {
				Paywall(isPresented: $showPaywall)
			}
			.alert(GetPlusPaywallInformation.ingredients.title, isPresented: $showPaywallMessage, actions: {
				Button("Upgrade", role: .confirm) {
					showPaywall.toggle()
				}
			}, message: {
				Text(GetPlusPaywallInformation.ingredients.description)
			})
	}
}

extension View {
	
	/// Sets a rounded rectangle as a clipping shape for this view
	func paywallViewModifier(showPaywallMessage: Binding<Bool>, showPaywall: Binding<Bool>) -> some View {
		return modifier(PaywallViewModifier(showPaywallMessage: showPaywallMessage, showPaywall: showPaywall))
	}
}

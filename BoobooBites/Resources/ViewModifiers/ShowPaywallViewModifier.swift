//
//  ShowPaywallViewModifier.swift
//  BoobooBites
//
//  Created by Ryan Rook on 26/03/2026.
//

import SwiftUI

protocol ShowPaywall {
	
	var showPaywallMessage: Bool { get set }
	var paywallMessage: PaywallMessage { get }
	
	var showPaywall: Bool { get set }
	
}

private struct ShowPaywallViewModifier: ViewModifier, ShowPaywall {
	// MARK: - properties
	@Binding var showPaywallMessage: Bool
	var paywallMessage: PaywallMessage
	
	@State var showPaywall: Bool = false
	// MARK: - body
	func body(content: Content) -> some View {
		content
			.sheet(isPresented: $showPaywall) {
				Paywall(isPresented: $showPaywall)
			}
			.alert(paywallMessage.title, isPresented: $showPaywallMessage, actions: {
				Button("Upgrade", role: .confirm) {
					showPaywall.toggle()
				}
			}, message: {
				Text(paywallMessage.description)
			})
	}
}

extension View {
	
	/// Sets a rounded rectangle as a clipping shape for this view
	func showPaywall(showPaywallMessage: Binding<Bool>, paywallMessage: PaywallMessage) -> some View {
		return modifier(ShowPaywallViewModifier(showPaywallMessage: showPaywallMessage, paywallMessage: paywallMessage))
	}
}

//
//  GetPlusButtonView.swift
//  BoobooBites
//
//  Created by Ryan Rook on 26/03/2026.
//

import SwiftUI

struct GetPlusButtonView: View {
	
	// MARK: - properties
	@State private var showPaywall = false
	
	// MARK: - body
	var body: some View {
		Button {
			showPaywall.toggle()
		} label: {
			LabeledContent {
				Image(systemName: "chevron.right")
					.foregroundStyle(.white)
			} label: {
				Label {
					Text("Booboo Bites +")
						.bold()
						.foregroundStyle(.white)
				} icon: {
					Image(systemName: ProAccessManager.premiumPurchased ? "heart" : "crown")
						.symbolVariant(.fill)
						.foregroundStyle(ProAccessManager.premiumPurchased ? .white : .yellow)
						.phaseAnimator([true, false]) { content, phase in
							content
								.scaleEffect(phase ? 1.01 : 1.0)
						} animation: { phase in
								.spring
						}
				}
			}
		}
		.listRowBackground(ProAccessManager.premiumPurchased ? Color(.sonicPink) : Color(.accent))
		.sheet(isPresented: $showPaywall) {
			Paywall(isPresented: $showPaywall)
		}
	}
}

#Preview {
	List {
		GetPlusButtonView()
	}
}

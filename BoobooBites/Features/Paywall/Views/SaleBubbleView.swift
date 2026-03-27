//
//  SaleBubbleView.swift
//  Icebreaker
//
//  Created by Ryan Rook on 29/09/2025.
//

import SwiftUI

#Preview {
	SaleBubbleView()
}

struct SaleBubbleView: View {
	var body: some View {
		Text(Date.isDateInSaleRange() ? "33% OFF" : "One Time Purchase")
			.foregroundStyle(.white)
			.font(.callout)
			.bold()
			.padding(6)
			.glassEffectStyle(color: Date.isDateInSaleRange() ? Color(.red) : Color(.orange))
			.phaseAnimator([true, false]) { content, phase in
				content
					.scaleEffect(phase ? 1.03 : 1.0)
			} animation: { phase in
					.bouncy
			}
	}
}

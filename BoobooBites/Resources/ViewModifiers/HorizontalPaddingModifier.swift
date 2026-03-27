//
//  HorizontalPaddingModifier.swift
//  BoobooBites
//
//  Created by Ryan Rook on 25/03/2026.
//

import SwiftUI

private protocol HorizontalPadding {
	
	var edge: Edge.Set { get }
	var length: Int { get }
	var paddingMultiplier: Int { get }
}

private struct HorizontalPaddingModifier: ViewModifier, HorizontalPadding {
	
	var edge: Edge.Set = .horizontal
	var length: Int = 9
	var paddingMultiplier: Int = 1
	
	func body(content: Content) -> some View {
		content
			.padding(edge, CGFloat(length * paddingMultiplier))
	}
}

extension View {
	
	func horizontalPadding(paddingMultiplier: Int? = nil) -> some View {
		guard let value = paddingMultiplier else { return modifier(HorizontalPaddingModifier()) }
		return modifier(HorizontalPaddingModifier(paddingMultiplier: value))
	}
}

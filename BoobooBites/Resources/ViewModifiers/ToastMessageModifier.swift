//
//  ToastMessageModifier.swift
//  BoobooBites
//
//  Created by Ryan Rook on 30/03/2026.
//

import SwiftUI

private protocol ToastMessage {
	
	var isActive: Binding<Bool> { get set }
	var color: Color { get set }
	var title: String { get set }
	var image: String { get set }
}

private struct ToastMessageModifier: ViewModifier, ToastMessage {
	
	var isActive: Binding<Bool>
	var color: Color
	var title: String
	var image: String
	
	func body(content: Content) -> some View {
		content
			.overlay(alignment: .top) {
				if isActive.wrappedValue {
					Label(title, systemImage: image)
						.foregroundStyle(.white)
						.font(.caption)
						.padding()
						.glassEffectStyle(color: color)
						.transition(.asymmetric(insertion: .push(from: .top), removal: .opacity))
						.padding(9)
				}
			}
	}
}

extension View {
	
	func toastMessage(isActive: Binding<Bool>, color: Color, title: String, image: String) -> some View {
		return modifier(ToastMessageModifier(isActive: isActive, color: color, title: title, image: image))
	}
}

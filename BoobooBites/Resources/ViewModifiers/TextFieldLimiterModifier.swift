//
//  TextFieldLimiterModifier.swift
//  BoobooBites
//
//  Created by Ryan Rook on 24/03/2026.
//

import SwiftUI
import Combine

private protocol TextFieldLimiter {
	
	func limitText(_ text: Binding<String>, limit: Int)
}

private extension TextFieldLimiter {
	
	func limitText(_ text: Binding<String>, limit: Int) {
		if text.wrappedValue.count > limit {
			text.wrappedValue = String(text.wrappedValue.prefix(limit))
		}
	}
}

private struct TextFieldLimiterModifier: ViewModifier, TextFieldLimiter {
	
	@Binding var text: String
	var limit: Int
	
	func body(content: Content) -> some View {
		content
			.onReceive(Just(text)) { _ in limitText($text, limit: limit) }
	}
}

extension View {
	
	/// Limit the maximum number of characters in a text field
	func textFieldLimiter(text: Binding<String>, limit: Int) -> some View {
		return modifier(TextFieldLimiterModifier(text: text, limit: limit))
	}
}

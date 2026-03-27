//
//  ImageGlassEffectStyleModifier.swift
//  BoobooBites
//
//  Created by Ryan Rook on 25/03/2026.
//

import SwiftUI

private struct ImageGlassEffectStyleModifier: ViewModifier {
	
	var isOn: Bool = true
	
	var color: Color? = nil
	var interactive: Bool? = nil
	var cornerRadius: CGFloat = 24
	
	func body(content: Content) -> some View {
		if isOn {
			if let color = color {
				if let interactive = interactive {
					content
						.corneredRadius()
						.glassEffectStyle(color: color, interactive: interactive, cornerRadius: cornerRadius)
						.shadow(radius: 2.2)
				} else {
					content
						.corneredRadius()
						.glassEffectStyle(color: color, cornerRadius: cornerRadius)
						.shadow(radius: 2.2)
				}
			} else {
				if let interactive = interactive {
					content
						.corneredRadius()
						.glassEffectStyle(interactive: interactive, cornerRadius: cornerRadius)
						.shadow(radius: 2.2)
				} else {
					content
						.corneredRadius()
						.glassEffectStyle(cornerRadius: cornerRadius)
						.shadow(radius: 2.2)
				}
			}
		} else {
			content
		}
	}
}

extension View {
	
	func imageGlassEffectStyleModifier(isOn: Bool = true, color: Color? = nil, interactive: Bool? = nil, cornerRadius: CGFloat = 24) -> some View {
		return modifier(ImageGlassEffectStyleModifier(isOn: isOn, color: color, interactive: interactive, cornerRadius: cornerRadius))
	}
}

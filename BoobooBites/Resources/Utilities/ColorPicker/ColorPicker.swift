//
//  ColorPicker.swift
//  BoobooBites
//
//  Created by Ryan Rook on 21/03/2026.
//

import SwiftUI

///
/// Color Picker
///
#Preview {
	List {
		ColorPickerView(selectedColor: .constant(.appleRed))
	}
}

struct ColorPickerView: View {
	
	// MARK: - properties
	@Binding var selectedColor: Color
	// MARK: - body
	var body: some View {
		ScrollViewReader { reader in
			ScrollView(.horizontal, showsIndicators: false) {
				Grid {
					GridRow {
						
						ForEach(Color.allColors, id: \.self) { color in
							colorButton(color)
								.scrollTransition { effect, phase in
									effect
										.opacity(phase.isIdentity ? 1 : 0.8)
										.blur(radius: phase.isIdentity ? 0 : 0.6)
								}
						}
						
					}
				}
			}
			.scrollClipDisabled()
			.onAppear {
				reader.scrollTo(selectedColor)
			}
		}
	}
}

extension ColorPickerView {
	
	@ViewBuilder
	private func colorButton(_ color: Color) -> some View {
		Button {
			setColor(color)
		} label: {
			Circle()
				.foregroundStyle(color.gradient)
				.frame(width: 32, height: 32)
				.overlay(alignment: .center) {
					if color == selectedColor {
						Circle()
							.frame(width: 6, height: 6)
							.foregroundStyle(.white)
					}
				}
		}
		.scrollTransition { effect, phase in
			effect
				.scaleEffect(phase.isIdentity ? 1 : 0.8)
				.opacity(phase.isIdentity ? 1 : 0.9)
				.blur(radius: phase.isIdentity ? 0 : 0.8)
		}
	}
	
	private func setColor(_ color: Color) {
		withAnimation {
			selectedColor = color
		}
	}
}

///
/// String Color Picker
///
#Preview {
	List {
		StringColorPickerView(selectedColor: .constant("appleOrange"))
	}
}

struct StringColorPickerView: View {
	// MARK: - properties
	@Binding var selectedColor: String
	// MARK: - body
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			Grid {
				GridRow {
					ForEach(Color.allColors, id: \.self) { color in
						colorButton(color)
							.scrollTransition { effect, phase in
								effect
									.opacity(phase.isIdentity ? 1 : 0.8)
									.blur(radius: phase.isIdentity ? 0 : 0.6)
							}
					}
				}
			}
		}
	}
}

extension StringColorPickerView {
	
	@ViewBuilder
	private func colorButton(_ color: Color) -> some View {
		Button {
			setColor(color)
		} label: {
			Circle()
				.foregroundStyle(color.gradient)
				.frame(width: 32, height: 32)
				.overlay(alignment: .center) {
					if Color.convertColorToString(color) == selectedColor {
						Circle()
							.frame(width: 6, height: 6)
							.foregroundStyle(.white)
					}
				}
		}
	}
	
	private func setColor(_ color: Color) {
		withAnimation {
			selectedColor = Color.convertColorToString(color)
		}
	}
}

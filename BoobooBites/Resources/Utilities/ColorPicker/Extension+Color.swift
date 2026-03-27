//
//  Extension+Color.swift
//  BoobooBites
//
//  Created by Ryan Rook on 21/03/2026.
//

import SwiftUI

extension Color {
	
	static let allColors: [Color] = [appleRed, appleOrange, appleYellow, appleGreen, appleMint, appleTeal, appleCyan, appleBlue, appleIndigo, applePurple, applePink, appleCoral, appleBrown, appleGray]
	
	static func convertColorToString(_ selectedColor: Color) -> String {
		switch selectedColor {
		case .appleRed:
			return "appleRed"
		case .appleOrange:
			return "appleOrange"
		case .appleYellow:
			return "appleYellow"
		case .appleGreen:
			return "appleGreen"
		case .appleMint:
			return "appleMint"
		case .appleTeal:
			return "appleTeal"
		case .appleCyan:
			return "appleCyan"
		case .appleBlue:
			return "appleBlue"
		case .appleIndigo:
			return "appleIndigo"
		case .applePurple:
			return "applePurple"
		case .applePink:
			return "applePink"
		case .appleCoral:
			return "appleCoral"
		case .appleBrown:
			return "appleBrown"
		case .appleGray:
			return "appleGray"
		default:
			return "appleRed"
		}
	}
	
	static func convertStringToColor(_ colorString: String) -> Color {
		switch colorString {
		case "appleRed":
			return .appleRed
		case "appleOrange":
			return .appleOrange
		case "appleYellow":
			return .appleYellow
		case "appleGreen":
			return .appleGreen
		case "appleMint":
			return .appleMint
		case "appleTeal":
			return .appleTeal
		case "appleCyan":
			return .appleCyan
		case "appleBlue":
			return .appleBlue
		case "appleIndigo":
			return .appleIndigo
		case "applePurple":
			return .applePurple
		case "applePink":
			return .applePink
		case "appleCoral":
			return .appleCoral
		case "appleBrown":
			return .appleBrown
		case "appleGray":
			return .appleGray
		default:
			return .appleRed
		}
	}
}


//
//  Extension+Color.swift
//  BoobooBites
//
//  Created by Ryan Rook on 21/03/2026.
//

import SwiftUI

extension Color {
	
	static let rgbColors: [Color] = [appleRed, appleGreen, appleBlue]
	
	static let lockedColors: [Color] = [appleOrange, appleYellow, appleMint, appleTeal, appleCyan, appleIndigo, applePurple, applePink, appleBrown, appleGray, sonicRed, tailsOrange, sonicYellow, sonicGreen, sonicBlue, sonicPurple, sonicGray, vintageMist, vintageSlate, vintageAmber, vintageSky, vintageBrick, vintageCopper, vintageAqua, vintageSunset, vintageBlush, vintageSand, vintageTaupe, vintageMoss, vintageHoney, vintageMaple, vintageMint, vintageGold, vintageScarlet, vintageAzure, vintageRose, vintageFern]
	
	static let allColors: [Color] = [appleRed, appleOrange, appleYellow, appleGreen, appleMint, appleTeal, appleCyan, appleBlue, appleIndigo, applePurple, applePink, appleCoral, appleBrown, appleGray, sonicRed, tailsOrange, sonicYellow, sonicGreen, sonicBlue, sonicPurple, sonicGray, vintageMist, vintageSlate, vintageAmber, vintageSky, vintageBrick, vintageCopper, vintageAqua, vintageSunset, vintageBlush, vintageSand, vintageTaupe, vintageMoss, vintageHoney, vintageMaple, vintageMint, vintageGold, vintageScarlet, vintageAzure, vintageRose, vintageFern]
	
	static let allSonicColors: [Color] = [sonicRed, tailsOrange, sonicYellow, sonicGreen, sonicBlue, sonicPurple, sonicGray]
	
	static let allVintageColors: [Color] = [vintageMist, vintageSlate, vintageAmber, vintageSky, vintageBrick, vintageCopper, vintageAqua, vintageSunset, vintageBlush, vintageSand, vintageTaupe, vintageMoss, vintageHoney, vintageMaple, vintageMint, vintageGold, vintageScarlet, vintageAzure, vintageRose, vintageFern]
	
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
		case .sonicRed:
			return "sonicRed"
		case .tailsOrange:
			return "tailsOrange"
		case .sonicYellow:
			return "sonicYellow"
		case .sonicGreen:
			return "sonicGreen"
		case .sonicBlue:
			return "sonicBlue"
		case .sonicPurple:
			return "sonicPurple"
		case .sonicGray:
			return "sonicGray"
		case vintageMist:
			return "vintageMist"
		case vintageSlate:
			return "vintageSlate"
		case vintageAmber:
			return "vintageAmber"
		case vintageSky:
			return "vintageSky"
		case vintageBrick:
			return "vintageBrick"
		case vintageCopper:
			return "vintageCopper"
		case vintageAqua:
			return "vintageAqua"
		case vintageSunset:
			return "vintageSunset"
		case vintageBlush:
			return "vintageBlush"
		case vintageSand:
			return "vintageSand"
		case vintageTaupe:
			return "vintageTaupe"
		case vintageMoss:
			return "vintageMoss"
		case vintageHoney:
			return "vintageHoney"
		case vintageMaple:
			return "vintageMaple"
		case vintageMint:
			return "vintageMint"
		case vintageGold:
			return "vintageGold"
		case vintageScarlet:
			return "vintageScarlet"
		case vintageAzure:
			return "vintageAzure"
		case vintageRose:
			return "vintageRose"
		case vintageFern:
			return "vintageFern"
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
		case "sonicRed":
			return .sonicRed
		case "tailsOrange":
			return tailsOrange
		case "sonicYellow":
			return .sonicYellow
		case "sonicGreen":
			return .sonicGreen
		case "sonicBlue":
			return .sonicBlue
		case "sonicPurple":
			return .sonicPurple
		case "sonicGray":
			return .sonicGray
		case "vintageMist":
			return vintageMist
		case "vintageSlate":
			return vintageSlate
		case "vintageAmber":
			return vintageAmber
		case "vintageSky":
			return vintageSky
		case "vintageBrick":
			return vintageBrick
		case "vintageCopper":
			return vintageCopper
		case "vintageAqua":
			return vintageAqua
		case "vintageSunset":
			return vintageSunset
		case "vintageBlush":
			return vintageBlush
		case "vintageSand":
			return vintageSand
		case "vintageTaupe":
			return vintageTaupe
		case "vintageMoss":
			return vintageMoss
		case "vintageHoney":
			return vintageHoney
		case "vintageMaple":
			return vintageMaple
		case "vintageMint":
			return vintageMint
		case "vintageGold":
			return vintageGold
		case "vintageScarlet":
			return vintageScarlet
		case "vintageAzure":
			return vintageAzure
		case "vintageRose":
			return vintageRose
		case "vintageFern":
			return vintageFern
		default:
			return .appleRed
		}
	}
}


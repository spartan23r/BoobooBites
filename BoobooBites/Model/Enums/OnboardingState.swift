//
//  OnboardingState.swift
//  BoobooBites
//
//  Created by Ryan Rook on 25/03/2026.
//

import SwiftUI

enum OnboardingState: Int, CaseIterable, Codable {
	case welcome, page1, page2, page3, finished
	
	var title: String {
		switch self {
		case .welcome, .finished: "Booboo Bites"
		case .page1: "Not sure what to eat today?"
		case .page2: "Make the most of what you have"
		case .page3: "Enjoy every bite"
		}
	}
	
	var description: String {
		switch self {
		case .welcome, .finished: "Plan your meals with love."
		case .page1: "Find and organize your favorite recipes in one place."
		case .page2: "Turn your ingredients into simple, delicious meals."
		case .page3: "Relax and enjoy meals you’ve planned with ease."
		}
	}
	
	var buttonTitle: String {
		switch self {
		case .welcome: "Continue"
		case .page1: "Next"
		case .page2: "Next"
		case .page3, .finished: "Start cooking"
		}
	}
	
	var image: Image {
		switch self {
		case .welcome, .finished: Image("bbb-logo-transparant")
		case .page1: Image("onboardingPage1Image")
		case .page2: Image("onboardingPage2Image")
		case .page3: Image("onboardingPage3Image")
		}
	}
}

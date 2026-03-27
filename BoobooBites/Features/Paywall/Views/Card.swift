//
//  Card.swift
//  InvitesIntroPage
//
//  Created by Balaji Venkatesh on 11/02/25.
//

import Foundation
import SwiftUI

struct Card: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var image: String
}

let paywallCards: [Card] = [
	.init(image: "onboardingPage1Image"),
	.init(image: "onboardingPage2Image"),
	.init(image: "onboardingPage3Image"),
	.init(image: "onboardingPage4Image"),
]

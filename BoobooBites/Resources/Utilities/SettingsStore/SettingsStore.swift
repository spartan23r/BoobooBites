//
//  SettingsStore.swift
//  BoobooBites
//
//  Created by Ryan Rook on 23/03/2026.
//

import SwiftUI
import Observation

@Observable
final class SettingsStore {
	
	@ObservationIgnored
	@AppStorage("enableHaptics") private var persistedEnableHaptics: Bool = true

	var enableHaptics: Bool = true {
		didSet {
			persistedEnableHaptics = enableHaptics
		}
	}

	init() {
		enableHaptics = persistedEnableHaptics
	}
}

extension SettingsStore {
	
	func triggerHaptic(_ trigger: inout Bool) {
		if enableHaptics {
			trigger.toggle()
		}
	}
	
}

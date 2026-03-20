//
//  Item.swift
//  BoobooBites
//
//  Created by Ryan Rook on 20/03/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

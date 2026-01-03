//
//  Item.swift
//  HabitTracker
//
//  Created by Zlatko Damcevski on 3/1/2026.
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

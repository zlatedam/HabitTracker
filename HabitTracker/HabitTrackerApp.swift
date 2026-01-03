//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Zlatko Damcevski on 3/1/2026.
//

import SwiftUI
import SwiftData

@main
struct HabitTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Habit.self)
    }
}

import SwiftData
import SwiftUI
import Foundation

@Model
class Habit {
    var id: UUID
    var name: String
    var colorHex: String
    var completedDays: [Int]
    var createdAt: Date
    
    init(name: String, colorHex: String) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.completedDays = []
        self.createdAt = Date()
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .gray
    }
    
    var completedCount: Int {
        completedDays.count
    }
    
    func isCompleted(day: Int) -> Bool {
        completedDays.contains(day)
    }
    
    func toggleDay(_ day: Int) {
        if let index = completedDays.firstIndex(of: day) {
            completedDays.remove(at: index)
        } else {
            completedDays.append(day)
            completedDays.sort()
        }
    }
    
    // MARK: - Streak Tracking
    
    /// Current streak (consecutive days including today)
    var currentStreak: Int {
        guard !completedDays.isEmpty else { return 0 }
        
        let today = getCurrentDayOfYear()
        let sorted = completedDays.sorted(by: >)
        
        // If today isn't completed, streak is broken
        guard sorted.first == today else { return 0 }
        
        var streak = 1
        var expectedDay = today - 1
        
        for day in sorted.dropFirst() {
            if day == expectedDay {
                streak += 1
                expectedDay -= 1
            } else {
                break
            }
        }
        
        return streak
    }
    
    /// Longest streak ever achieved
    var longestStreak: Int {
        guard !completedDays.isEmpty else { return 0 }
        
        let sorted = completedDays.sorted()
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 1..<sorted.count {
            if sorted[i] == sorted[i-1] + 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
    
    // MARK: - Milestones
    
    struct Milestone {
        let days: Int
        let emoji: String
        let title: String
    }
    
    static let milestones = [
        Milestone(days: 7, emoji: "🌱", title: "First Week"),
        Milestone(days: 30, emoji: "🔥", title: "One Month"),
        Milestone(days: 50, emoji: "⭐️", title: "50 Days"),
        Milestone(days: 100, emoji: "💎", title: "Century"),
        Milestone(days: 200, emoji: "🏆", title: "200 Club"),
        Milestone(days: 365, emoji: "👑", title: "Full Year")
    ]
    
    /// All achieved milestones
    var achievedMilestones: [Milestone] {
        Self.milestones.filter { completedCount >= $0.days }
    }
    
    /// Next milestone to achieve
    var nextMilestone: Milestone? {
        Self.milestones.first { completedCount < $0.days }
    }
    
    /// Progress to next milestone (0.0 to 1.0)
    var progressToNextMilestone: Double {
        guard let next = nextMilestone else { return 1.0 }
        
        // Find previous milestone or 0
        let previousMilestoneDays = Self.milestones
            .filter { $0.days < next.days }
            .last?.days ?? 0
        
        let range = Double(next.days - previousMilestoneDays)
        let progress = Double(completedCount - previousMilestoneDays)
        
        return min(progress / range, 1.0)
    }
    
    /// Days until next milestone
    var daysUntilNextMilestone: Int? {
        guard let next = nextMilestone else { return nil }
        return next.days - completedCount
    }
    
    // MARK: - Helpers
    
    private func getCurrentDayOfYear() -> Int {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Australia/Sydney")!
        return calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}

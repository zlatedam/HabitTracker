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

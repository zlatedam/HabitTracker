import SwiftUI

struct HabitWidgetView: View {
    let habit: Habit
    let currentDayOfYear: Int
    let onToggleDay: (Int) -> Void
    let onDelete: () -> Void
    
    let columns = 10  // Changed from rows
    let daysInYear = 365
    
    var rows: Int {  // Changed from columns
        Int(ceil(Double(daysInYear) / Double(columns)))
    }
    
    var isTodayCompleted: Bool {
        habit.isCompleted(day: currentDayOfYear)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                // Dot grid - now vertical orientation
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0..<columns, id: \.self) { col in
                                let dayNumber = col + (row * columns) + 1
                                if dayNumber <= daysInYear {
                                    DotButton(
                                        dayNumber: dayNumber,
                                        habit: habit,
                                        currentDay: currentDayOfYear,
                                        onToggle: onToggleDay
                                    )
                                }
                            }
                        }
                    }
                }
                
                // Quick action button
                Button {
                    onToggleDay(currentDayOfYear)
                } label: {
                    HStack(spacing: 6) {
                        if isTodayCompleted {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Today Complete")
                        } else {
                            Text("Mark Today Complete")
                        }
                    }
                    .font(.system(.caption, design: .monospaced, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isTodayCompleted ? Color.white.opacity(0.2) : Color.white.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                
                // Stats text
                HStack(alignment: .bottom) {
                    Text(habit.name.uppercased())
                        .font(.system(.subheadline, design: .monospaced, weight: .medium))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Text("\(habit.completedCount) days")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(20)
            .background(habit.color)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding(12)
        }
    }
}

struct DotButton: View {
    let dayNumber: Int
    let habit: Habit
    let currentDay: Int
    let onToggle: (Int) -> Void
    
    var isCompleted: Bool { habit.isCompleted(day: dayNumber) }
    var isPast: Bool { dayNumber <= currentDay }
    var isFuture: Bool { dayNumber > currentDay }
    var isToday: Bool { dayNumber == currentDay }
    
    var body: some View {
        Button {
            if isPast {
                onToggle(dayNumber)
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        } label: {
            Circle()
                .fill(dotColor)
                .frame(width: 4, height: 4)
                .overlay {
                    if isToday && !isCompleted {
                        Circle()
                            .strokeBorder(.white.opacity(0.5), lineWidth: 0.5)
                            .frame(width: 6, height: 6)
                    }
                }
        }
        .buttonStyle(.plain)
        .frame(width: 12, height: 12)
        .contentShape(Rectangle())
        .disabled(isFuture)
    }
    
    var dotColor: Color {
        if isCompleted {
            return .white.opacity(0.9)
        } else if isFuture {
            return .white.opacity(0.15)
        } else {

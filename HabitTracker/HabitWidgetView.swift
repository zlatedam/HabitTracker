import SwiftUI
import SwiftData

struct HabitWidgetView: View {
    @Bindable var habit: Habit
    let currentDay: Int
    
    @State private var isZoomed = false
    @State private var showingDeleteAlert = false
    @State private var isToggling = false
    @Environment(\.modelContext) private var modelContext
    
    let dotsPerRow = 73  // Days per row
    let daysInYear = 365
    
    var totalRows: Int {
        Int(ceil(Double(daysInYear) / Double(dotsPerRow)))
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: isZoomed ? 2 : 1) {
                            ForEach(0..<totalRows, id: \.self) { row in
                                HStack(spacing: isZoomed ? 2 : 1) {
                                    ForEach(0..<dotsPerRow, id: \.self) { col in
                                        let dayNumber = (row * dotsPerRow) + col + 1
                                        if dayNumber <= daysInYear {
                                            makeDot(for: dayNumber)
                                                .id(dayNumber)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: isZoomed ? 60 : 40)
                    .clipped()
                    .onAppear {
                        proxy.scrollTo(1, anchor: .leading)
                    }
                }
                
                Button {
                    toggleDay(currentDay)
                } label: {
                    HStack(spacing: 6) {
                        if habit.isCompleted(day: currentDay) {
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
                    .background(habit.isCompleted(day: currentDay) ? Color.white.opacity(0.2) : Color.white.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                HStack(alignment: .bottom) {
                    Text(habit.name.uppercased())
                        .font(.system(.caption, design: .monospaced, weight: .medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("\(habit.completedCount) days")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(14)
            .background(habit.color)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            HStack(spacing: 8) {
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        isZoomed.toggle()
                    }
                } label: {
                    Image(systemName: isZoomed ? "minus.magnifyingglass" : "plus.magnifyingglass")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(.white.opacity(0.2))
                        .clipShape(Circle())
                }
                
                Button {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(.white.opacity(0.2))
                        .clipShape(Circle())
                }
                .alert("Delete Habit?", isPresented: $showingDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        modelContext.delete(habit)
                    }
                } message: {
                    Text("Are you sure you want to delete '\(habit.name)'? This action cannot be undone.")
                }
            }
            .padding(10)
        }
    }
    
    @ViewBuilder
    func makeDot(for dayNumber: Int) -> some View {
        let isCompleted = habit.isCompleted(day: dayNumber)
        let isPast = dayNumber <= currentDay
        let isToday = dayNumber == currentDay
        
        Button {
            if isPast {
                toggleDay(dayNumber)
            }
        } label: {
            Circle()
                .fill(dotColor(isCompleted: isCompleted, isPast: isPast))
                .frame(width: isZoomed ? 4 : 2, height: isZoomed ? 4 : 2)
                .overlay {
                    if isToday && !isCompleted {
                        Circle()
                            .strokeBorder(.white.opacity(0.6), lineWidth: 1)
                            .frame(width: isZoomed ? 8 : 5, height: isZoomed ? 8 : 5)
                    }
                }
                .frame(width: isZoomed ? 12 : 8, height: isZoomed ? 12 : 8)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isPast)
    }
    
    func toggleDay(_ day: Int) {
        guard !isToggling else { return }
        isToggling = true
        
        withAnimation(.spring(duration: 0.2)) {
            habit.toggleDay(day)
        }
        try? modelContext.save()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isToggling = false
        }
    }
    
    func dotColor(isCompleted: Bool, isPast: Bool) -> Color {
        if isCompleted {
            return .white.opacity(0.9)
        } else if !isPast {
            return .white.opacity(0.15)
        } else {
            return .white.opacity(0.3)
        }
    }
}

import SwiftUI
import SwiftData

struct HabitWidgetView: View {
    @Bindable var habit: Habit
    let currentDay: Int
    
    @State private var isZoomed = false
    @State private var showingDeleteAlert = false
    @State private var isToggling = false
    @State private var showMilestoneSheet = false
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
                
                // Streaks & Milestones Section
                VStack(spacing: 6) {
                    // Streaks Row
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 10))
                            Text("\(habit.currentStreak)")
                                .font(.system(.caption, design: .monospaced, weight: .bold))
                            Text("current")
                                .font(.system(.caption2, design: .monospaced))
                                .opacity(0.7)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                            Text("\(habit.longestStreak)")
                                .font(.system(.caption, design: .monospaced, weight: .bold))
                            Text("best")
                                .font(.system(.caption2, design: .monospaced))
                                .opacity(0.7)
                        }
                    }
                    .foregroundStyle(.white)
                    
                    // Next Milestone
                    if let next = habit.nextMilestone, let daysLeft = habit.daysUntilNextMilestone {
                        Button {
                            showMilestoneSheet = true
                        } label: {
                            HStack(spacing: 6) {
                                Text(next.emoji)
                                    .font(.system(size: 12))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 4) {
                                        Text("\(daysLeft) to \(next.title)")
                                            .font(.system(.caption2, design: .monospaced, weight: .medium))
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 8, weight: .bold))
                                    }
                                    
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(.white.opacity(0.2))
                                            
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(.white.opacity(0.8))
                                                .frame(width: geo.size.width * habit.progressToNextMilestone)
                                        }
                                    }
                                    .frame(height: 3)
                                }
                                
                                Spacer()
                            }
                            .foregroundStyle(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 8)
                            .background(.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    } else {
                        // All milestones achieved!
                        HStack(spacing: 6) {
                            Text("👑")
                                .font(.system(size: 12))
                            Text("All milestones achieved!")
                                .font(.system(.caption2, design: .monospaced, weight: .medium))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
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
        .sheet(isPresented: $showMilestoneSheet) {
            MilestoneDetailView(habit: habit)
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

// MARK: - Milestone Detail View
struct MilestoneDetailView: View {
    @Bindable var habit: Habit
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text(habit.name)
                            .font(.title2.bold())
                        Text("\(habit.completedCount) days completed")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top)
                    
                    // All Milestones
                    VStack(spacing: 12) {
                        ForEach(Habit.milestones, id: \.days) { milestone in
                            let achieved = habit.completedCount >= milestone.days
                            
                            HStack(spacing: 16) {
                                Text(milestone.emoji)
                                    .font(.system(size: 32))
                                    .frame(width: 50)
                                    .opacity(achieved ? 1 : 0.3)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(milestone.title)
                                        .font(.headline)
                                    Text("\(milestone.days) days")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                if achieved {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                        .font(.title2)
                                } else {
                                    Text("\(milestone.days - habit.completedCount) to go")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding()
                            .background(achieved ? habit.color.opacity(0.1) : Color.gray.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Milestones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

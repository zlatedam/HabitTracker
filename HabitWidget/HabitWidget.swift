import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), habits: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), habits: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let habits = fetchHabits()
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, habits: habits)
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    func fetchHabits() -> [Habit] {
        do {
            let container = try ModelContainer(for: Habit.self)
            let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.createdAt)])
            
            // Create a new ModelContext instead of using mainContext
            let context = ModelContext(container)
            let habits = try context.fetch(descriptor)
            return habits
        } catch {
            print("Failed to fetch habits: \(error)")
            return []
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let habits: [Habit]
}

struct HabitWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var currentDayOfYear: Int {
        Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
    }
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(habits: entry.habits, currentDay: currentDayOfYear)
        case .systemMedium:
            MediumWidgetView(habits: entry.habits, currentDay: currentDayOfYear)
        case .systemLarge:
            LargeWidgetView(habits: entry.habits, currentDay: currentDayOfYear)
        default:
            Text("Unsupported")
        }
    }
}

// Small Widget - Shows first habit with mini grid
struct SmallWidgetView: View {
    let habits: [Habit]
    let currentDay: Int
    
    var body: some View {
        if let habit = habits.first {
            VStack(alignment: .leading, spacing: 8) {
                Text(habit.name.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                // Mini dot grid (7 days)
                HStack(spacing: 1) {
                    ForEach(max(1, currentDay - 6)...currentDay, id: \.self) { day in
                        Circle()
                            .fill(habit.isCompleted(day: day) ? Color.white.opacity(0.9) : Color.white.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
                
                Spacer()
                
                Text("\(habit.completedCount) days")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(habit.color)
        } else {
            Text("No habits")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// Medium Widget - Shows 2 habits side by side
struct MediumWidgetView: View {
    let habits: [Habit]
    let currentDay: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(habits.prefix(2)) { habit in
                VStack(alignment: .leading, spacing: 6) {
                    Text(habit.name.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    // Mini grid (14 days, 2 rows)
                    VStack(spacing: 1) {
                        ForEach(0..<2) { row in
                            HStack(spacing: 1) {
                                ForEach(0..<7) { col in
                                    let day = max(1, currentDay - 13) + (row * 7) + col
                                    if day <= currentDay {
                                        Circle()
                                            .fill(habit.isCompleted(day: day) ? Color.white.opacity(0.9) : Color.white.opacity(0.3))
                                            .frame(width: 4, height: 4)
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Text("\(habit.completedCount) days")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(habit.color)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(8)
    }
}

// Large Widget - Shows all habits stacked
struct LargeWidgetView: View {
    let habits: [Habit]
    let currentDay: Int
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(habits.prefix(4)) { habit in
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(habit.name.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Text("\(habit.completedCount) days")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Last 21 days (3 rows × 7 cols)
                    VStack(spacing: 1) {
                        ForEach(0..<3) { row in
                            HStack(spacing: 1) {
                                ForEach(0..<7) { col in
                                    let day = max(1, currentDay - 20) + (row * 7) + col
                                    if day <= currentDay {
                                        Circle()
                                            .fill(habit.isCompleted(day: day) ? Color.white.opacity(0.9) : Color.white.opacity(0.3))
                                            .frame(width: 4, height: 4)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(12)
                .background(habit.color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }
}

struct HabitWidget: Widget {
    let kind: String = "HabitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HabitWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Habit Tracker")
        .description("Track your daily habits at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    HabitWidget()
} timeline: {
    SimpleEntry(date: .now, habits: [])
}

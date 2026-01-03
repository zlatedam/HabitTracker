import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Habit.createdAt) var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @State private var showingAddSheet = false
    
    var currentDayOfYear: Int {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Australia/Sydney")!
        let now = Date()
        let day = calendar.ordinality(of: .day, in: .year, for: now) ?? 1
        print("🕐 Current date: \(now)")
        print("🕐 Current day: \(day)")
        print("🕐 Timezone: \(calendar.timeZone.identifier)")
        return day
    }
    
    var daysLeftInYear: Int {
        365 - currentDayOfYear
    }
    
    var backgroundGradient: some View {
        Group {
            if colorScheme == .dark {
                LinearGradient(
                    colors: [
                        Color(red: 0.176, green: 0.176, blue: 0.227),
                        Color(red: 0.122, green: 0.122, blue: 0.180)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                Color(red: 0.976, green: 0.973, blue: 0.969)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                if habits.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(habits) { habit in
                                HabitWidgetView(habit: habit, currentDay: currentDayOfYear)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddHabitView()
            }
        }
    }
    
    var emptyState: some View {
        VStack(spacing: 20) {
            Text("📊")
                .font(.system(size: 80))
            Text("No Habits Yet")
                .font(.title2)
                .fontWeight(.bold)
            Text("Tap + to create your first habit tracker")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Habit.self, inMemory: true)
}

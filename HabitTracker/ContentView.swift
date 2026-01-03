import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Habit.createdAt) var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSheet = false
    
    var currentDayOfYear: Int {
        Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
    }
    
    var daysLeftInYear: Int {
        365 - currentDayOfYear
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if habits.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(habits) { habit in
                                HabitWidgetView(
                                    habit: habit,
                                    currentDayOfYear: currentDayOfYear,
                                    onToggleDay: { day in
                                        withAnimation(.spring(duration: 0.3)) {
                                            habit.toggleDay(day)
                                        }
                                        try? modelContext.save()
                                    },
                                    onDelete: {
                                        withAnimation {
                                            modelContext.delete(habit)
                                        }
                                    }
                                )
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
        .modelContainer(for: Habit.self)
}

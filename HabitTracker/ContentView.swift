import SwiftUI
import SwiftData
import UniformTypeIdentifiers  // ← Add this line

struct ContentView: View {
    @Query(sort: \Habit.createdAt) var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @State private var showingAddSheet = false
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var exportDocument: HabitBackupDocument?
    @State private var showingBackupAlert = false
    @State private var backupMessage = ""
    
    var currentDayOfYear: Int {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Australia/Sydney")!
        let now = Date()
        let day = calendar.ordinality(of: .day, in: .year, for: now) ?? 1
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
                    Menu {
                        Button {
                            showingAddSheet = true
                        } label: {
                            Label("New Habit", systemImage: "plus.circle")
                        }
                        
                        Divider()
                        
                        Button {
                            exportData()
                        } label: {
                            Label("Export Backup", systemImage: "square.and.arrow.up")
                        }
                        .disabled(habits.isEmpty)
                        
                        Button {
                            showingImportSheet = true
                        } label: {
                            Label("Import Backup", systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddHabitView()
            }
            .fileExporter(
                isPresented: $showingExportSheet,
                document: exportDocument,
                contentType: .json,
                defaultFilename: "HabitBackup-\(formattedDate()).json"
            ) { result in
                switch result {
                case .success:
                    backupMessage = "Backup exported successfully!"
                    showingBackupAlert = true
                case .failure(let error):
                    backupMessage = "Export failed: \(error.localizedDescription)"
                    showingBackupAlert = true
                }
            }
            .fileImporter(
                isPresented: $showingImportSheet,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                importData(result: result)
            }
            .alert("Backup", isPresented: $showingBackupAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(backupMessage)
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
            Text("Tap ⋯ to create your first habit tracker")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    
    func exportData() {
        guard let data = BackupManager.exportHabits(habits) else {
            backupMessage = "Failed to create backup"
            showingBackupAlert = true
            return
        }
        
        exportDocument = HabitBackupDocument(data: data)
        showingExportSheet = true
    }
    
    func importData(result: Result<[URL], Error>) {
        do {
            guard let selectedFile = try result.get().first else { return }
            
            // Access the file
            guard selectedFile.startAccessingSecurityScopedResource() else {
                backupMessage = "Could not access file"
                showingBackupAlert = true
                return
            }
            
            defer { selectedFile.stopAccessingSecurityScopedResource() }
            
            let data = try Data(contentsOf: selectedFile)
            try BackupManager.importHabits(from: data, context: modelContext)
            
            backupMessage = "Backup imported successfully! (\(habits.count) habits)"
            showingBackupAlert = true
            
        } catch {
            backupMessage = "Import failed: \(error.localizedDescription)"
            showingBackupAlert = true
        }
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Habit.self, inMemory: true)
}

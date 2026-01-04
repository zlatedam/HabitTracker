import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// MARK: - Backup Manager
class BackupManager {
    static func exportHabits(_ habits: [Habit]) -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let exportData = habits.map { habit in
            ExportableHabit(
                id: habit.id,
                name: habit.name,
                colorHex: habit.colorHex,
                completedDays: habit.completedDays,
                createdAt: habit.createdAt
            )
        }
        
        return try? encoder.encode(exportData)
    }
    
    static func importHabits(from data: Data, context: ModelContext) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let exportedHabits = try decoder.decode([ExportableHabit].self, from: data)
        
        for exportedHabit in exportedHabits {
            let habit = Habit(name: exportedHabit.name, colorHex: exportedHabit.colorHex)
            habit.id = exportedHabit.id
            habit.completedDays = exportedHabit.completedDays
            habit.createdAt = exportedHabit.createdAt
            context.insert(habit)
        }
        
        try context.save()
    }
}

// MARK: - Exportable Habit Model
struct ExportableHabit: Codable {
    let id: UUID
    let name: String
    let colorHex: String
    let completedDays: [Int]
    let createdAt: Date
}

// MARK: - Document Type for File Sharing
struct HabitBackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

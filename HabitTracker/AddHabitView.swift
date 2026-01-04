import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedColor = "#8BA888"
    
    // Adapting coulor theme from claude
    let colors = [
        "#8BA888", "#A8B5C8", "#C8B5A5",
        "#B8A8C8", "#C8A8A8", "#A8C8B8",
        "#D4A5A5", "#A5B4D4", "#C9D4A5"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Habit Details") {
                    TextField("Habit name", text: $name)
                        .textInputAutocapitalization(.words)
                }
                
                Section("Widget Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color) ?? .gray)
                                .frame(width: 60, height: 60)
                                .overlay {
                                    if selectedColor == color {
                                        Circle()
                                            .strokeBorder(.primary, lineWidth: 3)
                                    }
                                }
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addHabit()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addHabit() {
        let habit = Habit(name: name, colorHex: selectedColor)
        modelContext.insert(habit)
        dismiss()
    }
}

#Preview {
    AddHabitView()
}

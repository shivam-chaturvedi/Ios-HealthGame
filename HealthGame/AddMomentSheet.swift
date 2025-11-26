import SwiftUI

struct AddMomentSheet: View {
    @Binding var note: String
    @Binding var intensity: Double
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Note") {
                    TextField("Presentation stress", text: $note)
                }
                Section("Intensity") {
                    Slider(value: $intensity, in: 0...1)
                    Text(String(format: "%.0f%%", intensity * 100))
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add Moment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

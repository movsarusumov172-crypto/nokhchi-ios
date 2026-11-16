import SwiftUI

struct ProfileEditorView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Имя", text: $name).textContentType(.name)
                } footer: {
                    Text("До 80 символов. Изменения сохраняются только на этом iPhone.")
                }
                if let message = store.errorMessage {
                    Section { Text(message).foregroundStyle(.red) }
                }
            }
            .navigationTitle("Имя пользователя")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        store.setUserName(name)
                        if store.errorMessage == nil { dismiss() }
                    }
                    .disabled(
                        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            || name.count > 80)
                }
            }
        }
        .onAppear { name = store.state.userName }
    }
}

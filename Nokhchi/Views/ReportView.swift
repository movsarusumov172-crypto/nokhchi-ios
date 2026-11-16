import SwiftUI

struct ReportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var reason = "Спам"
    @State private var comment = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Причина") {
                    Picker("Причина", selection: $reason) {
                        Text("Спам").tag("Спам")
                        Text("Неприемлемый контент").tag("Неприемлемый контент")
                    }
                    TextField("Комментарий (необязательно)", text: $comment, axis: .vertical)
                }
                Section {
                    Text(
                        "Отправка жалоб недоступна без сервера Nokhchi. "
                            + "Данные этой формы никуда не отправляются."
                    )
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Пожаловаться")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Готово") { dismiss() } }
            }
        }
    }
}

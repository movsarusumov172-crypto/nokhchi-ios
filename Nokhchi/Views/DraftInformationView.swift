import SwiftUI

struct DraftInformationView: View {
    @Binding var draft: OrganizationDraft
    private let supportedLanguages = ["Русский", "English", "العربية", "Deutsch", "Türkçe", "Français"]

    var body: some View {
        Form {
            Section("Организация") {
                Picker("Категория", selection: $draft.category) {
                    ForEach(BusinessCategory.allCases) { Text($0.title).tag($0) }
                }
                TextField("Название", text: $draft.name).accessibilityIdentifier("draftName")
                TextField("Описание", text: $draft.note, axis: .vertical).lineLimit(4...10)
                Text("\(draft.note.count)/80 минимум для публикации")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section {
                TextField("Телефон", text: field(\.phone)).keyboardType(.phonePad)
                TextField("WhatsApp", text: field(\.whatsapp)).keyboardType(.phonePad)
                TextField("Telegram", text: field(\.telegram)).textInputAutocapitalization(.never)
                TextField("Instagram", text: field(\.instagram)).textInputAutocapitalization(.never)
                TextField("Сайт (https://…)", text: field(\.website))
                    .keyboardType(.URL).textInputAutocapitalization(.never)
            } header: {
                Text("Контакты")
            } footer: {
                Text("На снимке указан минимум один контакт для публикации. Черновик можно сохранить позже.")
            }
            Section("Языки обслуживания") {
                ForEach(supportedLanguages, id: \.self) { language in
                    Toggle(language, isOn: Binding(
                        get: { draft.languages?.contains(language) == true },
                        set: { selected in
                            var languages = draft.languages ?? []
                            if selected { languages.append(language) }
                            else { languages.removeAll { $0 == language } }
                            draft.languages = languages
                        }
                    ))
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func field(_ keyPath: WritableKeyPath<OrganizationDraft, String?>) -> Binding<String> {
        Binding(get: { draft[keyPath: keyPath] ?? "" }, set: { draft[keyPath: keyPath] = $0 })
    }
}

import SwiftUI

struct DraftEditorView: View {
    @State var draft: OrganizationDraft
    @State private var original: OrganizationDraft?
    @State private var showingDiscard = false
    @State private var showingMap = false
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Категория", selection: $draft.category) {
                        ForEach(BusinessCategory.allCases) { category in
                            Text(category.title).tag(category)
                        }
                    }
                    TextField("Название — до 120 символов", text: $draft.name)
                        .accessibilityIdentifier("draftName")
                    TextField("Город — до 100 символов", text: $draft.city)
                        .accessibilityIdentifier("draftCity")
                    TextField("Адрес — до 250 символов", text: $draft.address, axis: .vertical)
                        .lineLimit(2...4)
                } header: {
                    Text("Организация")
                } footer: {
                    Text("Обязательные поля: название и город. Адрес можно заполнить позже.")
                }
                Section("Описание") {
                    TextField("До 2000 символов", text: $draft.note, axis: .vertical)
                        .lineLimit(4...10)
                }
                Section {
                    Button(draft.location == nil ? "Указать точку на карте" : "Изменить точку",
                           systemImage: "mappin.and.ellipse") {
                        showingMap = true
                    }
                    if let point = draft.location {
                        Text("\(point.latitude.formatted()), \(point.longitude.formatted())")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button("Удалить точку", role: .destructive) { draft.location = nil }
                    }
                } footer: {
                    Text("Точка выбирается вручную. Геокодирование адреса не выполняется.")
                }
                Section {
                    if let message = store.errorMessage {
                        Text(message).foregroundStyle(.red)
                    }
                    if let message = draft.validationMessage {
                        Text(message).foregroundStyle(.secondary)
                    }
                    Text("Черновик хранится только на этом iPhone. "
                         + "Сервер, модерация и публикация к прототипу не подключены.")
                        .foregroundStyle(.secondary)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Черновик")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        if draft != original { showingDiscard = true } else { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        if store.saveDraft(draft) { dismiss() }
                    }
                    .disabled(draft.validationMessage != nil)
                }
            }
            .confirmationDialog("Не сохранять изменения?", isPresented: $showingDiscard,
                                titleVisibility: .visible) {
                Button("Не сохранять", role: .destructive) { dismiss() }
                Button("Продолжить редактирование", role: .cancel) { showingDiscard = false }
            }
            .sheet(isPresented: $showingMap) { LocationPickerView(point: $draft.location) }
        }
        .onAppear { if original == nil { original = draft } }
        .interactiveDismissDisabled(draft != original)
    }
}

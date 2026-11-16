import SwiftUI

struct DraftsView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedDraft: OrganizationDraft?
    @State private var deletingDraft: OrganizationDraft?

    var body: some View {
        List {
            Section {
                ForEach(store.state.drafts) { draft in
                    Button {
                        selectedDraft = draft
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(draft.name).font(.headline).foregroundStyle(.primary)
                            Text(draft.category.title).foregroundStyle(.secondary)
                            Text("\(draft.city) · Локальный черновик")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .swipeActions {
                        Button("Удалить", role: .destructive) { deletingDraft = draft }
                    }
                }
            } footer: {
                Text(
                    "Новые черновики создаются на вкладке «Добавить». "
                        + "Они не отправляются на сервер.")
            }
        }
        .overlay {
            if store.state.drafts.isEmpty {
                ContentUnavailableView(
                    "Нет черновиков", systemImage: "building.2",
                    description: Text("Создайте организацию во вкладке «Добавить».")
                )
                .allowsHitTesting(false)
            }
        }
        .navigationTitle("Мои бизнесы")
        .sheet(item: $selectedDraft) { draft in DraftEditorView(draft: draft) }
        .confirmationDialog(
            "Удалить локальный черновик?", isPresented: deletionPresented,
            titleVisibility: .visible
        ) {
            Button("Удалить черновик", role: .destructive) {
                if let deletingDraft { store.deleteDraft(deletingDraft) }
                deletingDraft = nil
            }
            Button("Отмена", role: .cancel) { deletingDraft = nil }
        }
    }

    private var deletionPresented: Binding<Bool> {
        Binding(get: { deletingDraft != nil }, set: { if !$0 { deletingDraft = nil } })
    }
}

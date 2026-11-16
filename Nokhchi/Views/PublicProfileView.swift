import SwiftUI

struct PublicProfileView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        List {
            Section { ProfileHeader(name: store.state.userName) }
            Section("Бизнесы участника") {
                if store.state.drafts.isEmpty {
                    Text("Нет локальных черновиков").foregroundStyle(.secondary)
                }
                ForEach(store.state.drafts) { draft in
                    NavigationLink { DraftPreviewView(draft: draft) } label: {
                        VStack(alignment: .leading) {
                            Text(draft.name)
                            Text("\(draft.city) · черновик")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Section {
                Text(
                    "Предпросмотр локального профиля. Публичная ссылка, "
                        + "статистика и серверная публикация не подключены."
                )
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Публичный профиль")
        .navigationBarTitleDisplayMode(.inline)
    }
}

import SwiftUI

struct PublicProfileView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        List {
            Section { ProfileHeader(name: store.state.userName) }
            Section("Бизнесы участника") {
                if let business = store.businesses.first(where: { $0.id == "screenshot-fullstack" })
                {
                    NavigationLink {
                        BusinessDetailView(business: business)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(business.name)
                            Text("Гудермес · данные со снимка")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                ForEach(store.state.drafts) { draft in
                    NavigationLink {
                        DraftPreviewView(draft: draft)
                    } label: {
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

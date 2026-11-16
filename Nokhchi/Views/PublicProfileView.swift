import SwiftUI

struct PublicProfileView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        List {
            Section { ProfileHeader(name: store.state.userName) }
            Section {
                Text("Предпросмотр локального профиля. Публичная ссылка, "
                     + "статистика и серверная публикация не подключены.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Публичный профиль")
        .navigationBarTitleDisplayMode(.inline)
    }
}

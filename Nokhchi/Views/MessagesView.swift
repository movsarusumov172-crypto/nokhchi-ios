import SwiftUI

struct MessagesView: View {
    var body: some View {
        List {
            Section {
                Text("Начните общение из профиля участника или владельца бизнеса.")
                Text("Переписка недоступна в прототипе: сервер Nokhchi не подключён.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Сообщения")
    }
}

import SwiftUI

struct VIPView: View {
    var body: some View {
        List {
            Section {
                Label {
                    Text("VIP-продвижение")
                } icon: {
                    Image(systemName: "crown.fill").foregroundStyle(vipGold)
                }
                    .font(.headline)
                Text("Статус подписки неизвестен: сервер Nokhchi не подключён.")
                    .foregroundStyle(.secondary)
            }
            Section("Мои VIP-места") {
                Text(
                    "На фото 6 показан один слот и отсутствие активных VIP-мест. "
                        + "Это состояние снимка, а не текущий тариф пользователя."
                )
                .foregroundStyle(.secondary)
            }
            Section {
                NavigationLink("Изменить тариф") {
                    UnavailableFeatureView(
                        title: "Тариф", symbol: "crown",
                        detail: "Тарифы и оплата недоступны без сервера.")
                }
                NavigationLink("Управлять подпиской") {
                    UnavailableFeatureView(
                        title: "Подписка", symbol: "creditcard",
                        detail: "Платёжные операции в прототипе не выполняются.")
                }
            }
        }
        .navigationTitle("VIP-продвижение")
        .navigationBarTitleDisplayMode(.inline)
    }
}

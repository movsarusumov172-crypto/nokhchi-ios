import SwiftUI

struct ProfileView: View {
    @Environment(AppStore.self) private var store
    @State private var editingProfile = false

    var body: some View {
        Form {
            Section {
                Button {
                    editingProfile = true
                } label: {
                    ProfileHeader(name: store.state.userName)
                }
                .buttonStyle(.plain)
            }
            Section {
                NavigationLink {
                    UnavailableFeatureView(
                        title: "Сообщения", symbol: "bubble.left.and.bubble.right",
                        detail: "Переписка требует сервера Nokhchi."
                    )
                } label: {
                    Label("Сообщения", systemImage: "bubble.left.and.bubble.right")
                }
                NavigationLink {
                    PublicProfileView()
                } label: {
                    Label("Мой публичный профиль", systemImage: "person.crop.circle")
                }
                NavigationLink {
                    DraftsView()
                } label: {
                    Label("Мои бизнесы", systemImage: "building.2")
                }
                NavigationLink {
                    VIPView()
                } label: {
                    Label("VIP-продвижение", systemImage: "crown")
                }
                NavigationLink {
                    FavoritesView()
                } label: {
                    Label("Избранное", systemImage: "heart")
                }
            }
            Section {
                Toggle(
                    isOn: Binding(
                        get: { store.state.notificationsEnabled },
                        set: { store.setNotifications($0) }
                    )
                ) {
                    Label("Уведомления", systemImage: "bell")
                }
                Picker(
                    selection: Binding(
                        get: { store.state.appearance },
                        set: { store.setAppearance($0) }
                    )
                ) {
                    ForEach(Appearance.allCases) { appearance in
                        Text(appearance.rawValue).tag(appearance)
                    }
                } label: {
                    Label("Оформление", systemImage: "circle.lefthalf.filled")
                }
                .pickerStyle(.navigationLink)
            } footer: {
                Text(
                    "Уведомления — локальная настройка. Push-сервис не подключён. "
                        + "Оформление применяется ко всему приложению и сохраняется.")
            }
            Section {
                informationLink(
                    "Условия использования", symbol: "doc.text",
                    detail: "Оригинальный текст условий не предоставлен. "
                        + "Прототип не публикует организации и не принимает оплату.")
                informationLink(
                    "Политика конфиденциальности", symbol: "hand.raised",
                    detail: "Оригинальная политика не предоставлена. Избранное, "
                        + "имя и черновики сохраняются локально. Apple Maps использует "
                        + "сетевые сервисы Apple. Геопозиция запрашивается только кнопкой.")
                informationLink(
                    "Заблокированные пользователи", symbol: "person.slash",
                    detail: "Список блокировок недоступен без сервера Nokhchi.")
                informationLink(
                    "Написать в поддержку", symbol: "envelope",
                    detail: "Контакт поддержки не предоставлен. "
                        + "Сообщения из прототипа не отправляются.")
            }
            Section {
                Text("Локальный профиль · Nokhchi Redesign")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(
                    "Вход и удаление серверного аккаунта недоступны: "
                        + "прототип не подключён к авторизации Nokhchi."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Профиль")
        .sheet(isPresented: $editingProfile) { ProfileEditorView() }
    }

    private func informationLink(_ title: String, symbol: String, detail: String) -> some View {
        NavigationLink {
            UnavailableFeatureView(title: title, symbol: symbol, detail: detail)
        } label: {
            Label(title, systemImage: symbol)
        }
    }
}

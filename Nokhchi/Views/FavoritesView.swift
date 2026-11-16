import SwiftUI

struct FavoritesView: View {
    @Environment(AppStore.self) private var store

    private var favorites: [Business] {
        store.businesses.filter { store.state.favorites.contains($0.id) }
    }

    var body: some View {
        List(favorites) { business in
            NavigationLink {
                BusinessDetailView(business: business)
            } label: {
                BusinessRow(business: business)
            }
        }
        .overlay {
            if favorites.isEmpty {
                ContentUnavailableView(
                    "Пока пусто", systemImage: "heart",
                    description: Text("Добавляйте организации из их карточек."))
            }
        }
        .navigationTitle("Избранное")
    }
}

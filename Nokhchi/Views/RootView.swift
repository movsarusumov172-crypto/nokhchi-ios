import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack { BusinessMapView() }
                .tabItem { Label("Карта", systemImage: "map") }
            NavigationStack { ExploreView() }
                .tabItem { Label("Обзор", systemImage: "magnifyingglass") }
            NavigationStack { CategorySelectionView() }
                .tabItem { Label("Добавить", systemImage: "plus.circle") }
            NavigationStack { ProfileView() }
                .tabItem { Label("Профиль", systemImage: "person.crop.circle") }
        }
    }
}

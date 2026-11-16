import SwiftUI

struct RootView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { BusinessMapView(selectedTab: $selectedTab) }
                .tabItem { Label("Карта", systemImage: "map") }
                .tag(0)
            NavigationStack { ExploreView() }
                .tabItem { Label("Обзор", systemImage: "magnifyingglass") }
                .tag(1)
            NavigationStack { CategorySelectionView() }
                .tabItem { Label("Добавить", systemImage: "plus.circle") }
                .tag(2)
            NavigationStack { ProfileView() }
                .tabItem { Label("Профиль", systemImage: "person.crop.circle") }
                .tag(3)
        }
    }
}

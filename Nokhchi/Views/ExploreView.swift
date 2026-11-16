import SwiftUI

struct ExploreView: View {
    @Environment(AppStore.self) private var store
    @State private var query = CatalogQuery()
    @State private var showingFilters = false

    private var results: [Business] {
        query.apply(to: store.businesses, favorites: store.state.favorites)
    }

    var body: some View {
        List {
            Section {
                CategoryStrip(selection: $query.category)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                filterControls
                    .listRowSeparator(.hidden)
            } footer: {
                DemoNotice()
            }
            Section {
                if results.isEmpty {
                    ContentUnavailableView(
                        "Ничего не найдено", systemImage: "magnifyingglass",
                        description: Text("Измените запрос, категорию или фильтры.")
                    )
                    .listRowSeparator(.hidden)
                }
                ForEach(results) { business in
                    NavigationLink(value: business) { BusinessRow(business: business) }
                }
            } header: {
                Text("Топ бизнесы").font(.title2.bold()).textCase(nil)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Обзор")
        .searchable(text: $query.text, placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Название, категория или город")
        .navigationDestination(for: Business.self) { business in
            BusinessDetailView(business: business)
        }
        .sheet(isPresented: $showingFilters) {
            CatalogFilterView(query: $query, cities: store.cities)
        }
    }

    private var filterControls: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                sortMenu
                Spacer()
                filterButton
            }
            VStack(alignment: .leading) {
                sortMenu
                filterButton
            }
        }
    }

    private var sortMenu: some View {
        Menu {
            Picker("Сортировка", selection: $query.sort) {
                ForEach(BusinessSort.allCases) { sort in Text(sort.rawValue).tag(sort) }
            }
        } label: {
            Label(query.sort.rawValue, systemImage: "arrow.up.arrow.down")
                .font(.subheadline)
                .padding(.vertical, 8)
        }
    }

    private var filterButton: some View {
        Button {
            showingFilters = true
        } label: {
            Label(
                query.city != nil || query.favoritesOnly ? "Фильтры включены" : "Фильтры",
                systemImage: "line.3.horizontal.decrease.circle"
            )
            .font(.subheadline)
            .padding(.vertical, 8)
        }
    }
}

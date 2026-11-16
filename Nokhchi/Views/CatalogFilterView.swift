import SwiftUI

struct CatalogFilterView: View {
    @Binding var query: CatalogQuery
    let cities: [String]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Показывать") {
                    Toggle("Только избранное", isOn: $query.favoritesOnly)
                    Picker("Город", selection: $query.city) {
                        Text("Все города").tag(String?.none)
                        ForEach(cities, id: \.self) { city in
                            Text(city).tag(Optional(city))
                        }
                    }
                }
                Section {
                    Button("Сбросить фильтры") {
                        query.city = nil
                        query.category = nil
                        query.favoritesOnly = false
                    }
                } footer: {
                    Text("Фильтр «Открыто сейчас» и расстояние недоступны: "
                         + "в материалах нет расписания и точных адресов.")
                }
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

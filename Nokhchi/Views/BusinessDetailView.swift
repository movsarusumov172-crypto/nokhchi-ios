import MapKit
import SwiftUI

struct BusinessDetailView: View {
    let business: Business
    @Environment(AppStore.self) private var store

    var body: some View {
        List {
            Section {
                Image(business.photo)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 240)
                    .accessibilityLabel("Фото организации со скриншота")
                    .listRowBackground(Color(uiColor: .systemBackground))
                Text(business.name).font(.title.bold()).textSelection(.enabled)
                Label(business.category.title, systemImage: business.category.symbol)
                if let city = business.city {
                    Label(city, systemImage: "mappin.and.ellipse")
                }
                if let rating = business.rating {
                    LabeledContent("Рейтинг на снимке", value: rating.formatted())
                }
                if let count = business.reviewCount {
                    LabeledContent("Отзывов на снимке", value: count.formatted())
                }
            }
            Section {
                Button {
                    store.toggleFavorite(business)
                } label: {
                    Label(
                        isFavorite ? "Убрать из избранного" : "В избранное",
                        systemImage: isFavorite ? "heart.fill" : "heart"
                    )
                }
                if let point = business.cityCenter {
                    Button("Показать город в Apple Maps", systemImage: "map") {
                        let item = MKMapItem(placemark: MKPlacemark(coordinate: point.coordinate))
                        item.name = business.city
                        item.openInMaps()
                    }
                }
            } footer: {
                Text("На карте будет показан центр города, а не адрес организации.")
            }
            Section("Источник данных") {
                DemoNotice()
                Text(
                    "Название, категория, город и рейтинг перенесены с фото 2. "
                        + "Точный адрес, контакты и расписание не предоставлены."
                )
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Организация")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.selection, trigger: isFavorite)
    }

    private var isFavorite: Bool { store.state.favorites.contains(business.id) }
}

extension GeoPoint {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static let gudermes = GeoPoint(latitude: 43.3519, longitude: 46.1036)
}

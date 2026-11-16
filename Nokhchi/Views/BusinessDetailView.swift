import MapKit
import SwiftUI

struct BusinessDetailView: View {
    let business: Business
    @Environment(AppStore.self) private var store
    @State private var showingReview = false
    @State private var showingReport = false
    @State private var mapError: String?

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
            if business.id == "screenshot-karak" {
                Section("Описание со снимка") {
                    Text("Ресторан Вайнахской кухни. Вкус, который помнят поколения. "
                         + "Халяльная еда и уютная атмосфера.")
                }
                Section("Контакты") {
                    Text("Телефон, WhatsApp, Instagram и сайт показаны на снимке, "
                         + "но их адреса не видны.").foregroundStyle(.secondary)
                }
                Section("Часы работы на снимке") {
                    LabeledContent("Каждый день", value: "09:00–01:30")
                    Text("Актуальное расписание не подтверждено.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Section("Язык обслуживания") { Text("Русский") }
                Section("Адрес на снимке") {
                    Text("Краснодарская улица 60А, Москва, Россия")
                    Button("Найти адрес в Apple Maps", systemImage: "map") {
                        Task { await openScreenshotAddress() }
                    }
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
                Text("Данные перенесены со снимков и могут быть устаревшими.")
                .foregroundStyle(.secondary)
            }
            Section("Отзывы") {
                if business.id == "screenshot-karak" {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("inbinb · 5 из 5").font(.headline)
                        Text("Живу рядом с местом, был не раз... кто хочет вспомнить "
                             + "домашний уют и вкус, место самое подходящее!")
                        Text("Отзыв со снимка").font(.caption).foregroundStyle(.secondary)
                    }
                }
                ForEach((store.state.reviews ?? []).filter { $0.businessID == business.id }) { review in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(review.author) · \(review.rating) из 5").font(.headline)
                        Text(review.text)
                        Text("Локальный отзыв").font(.caption).foregroundStyle(.secondary)
                    }
                }
                Button("Написать отзыв", systemImage: "square.and.pencil") { showingReview = true }
                Button("Пожаловаться", systemImage: "flag") { showingReport = true }
                ShareLink(item: "\(business.name) · \(business.category.title)") {
                    Label("Поделиться", systemImage: "square.and.arrow.up")
                }
            }
        }
        .navigationTitle("Организация")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.selection, trigger: isFavorite)
        .sheet(isPresented: $showingReview) { ReviewEditorView(business: business) }
        .sheet(isPresented: $showingReport) { ReportView() }
        .alert("Адрес", isPresented: Binding(
            get: { mapError != nil }, set: { if !$0 { mapError = nil } }
        )) {
            Button("Понятно", role: .cancel) { mapError = nil }
        } message: { Text(mapError ?? "") }
    }

    private var isFavorite: Bool { store.state.favorites.contains(business.id) }

    private func openScreenshotAddress() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Краснодарская улица 60А, Москва, Россия"
        do {
            let response = try await MKLocalSearch(request: request).start()
            guard let item = response.mapItems.first else {
                mapError = "Apple Maps не нашла адрес со снимка."
                return
            }
            item.openInMaps()
        } catch {
            mapError = "Не удалось найти адрес: \(error.localizedDescription)"
        }
    }
}

extension GeoPoint {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static let gudermes = GeoPoint(latitude: 43.3519, longitude: 46.1036)
}

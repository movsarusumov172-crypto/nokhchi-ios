import MapKit
import SwiftUI

struct LocationPickerView: View {
    @Binding var point: GeoPoint?
    @State private var candidate: GeoPoint?
    @State private var search = ""
    @State private var searchError: String?
    @State private var locationService = LocationService()
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: GeoPoint.gudermes.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        ))
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Map(position: $position) {
                if let candidate {
                    Marker("Выбранная точка", coordinate: candidate.coordinate)
                }
            }
            .overlay {
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundStyle(.primary)
                    .padding(8)
                    .background(.regularMaterial, in: Circle())
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                candidate = GeoPoint(
                    latitude: context.region.center.latitude,
                    longitude: context.region.center.longitude
                )
            }
            .safeAreaInset(edge: .top) {
                VStack {
                    TextField("Поиск адреса", text: $search)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.search)
                        .onSubmit { Task { await searchAddress() } }
                    HStack {
                        Button("Найти") { Task { await searchAddress() } }
                            .disabled(search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        Spacer()
                        Button("Моё место") { locationService.requestLocation() }
                            .disabled(locationService.isRequesting)
                    }
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
            }
            .onChange(of: locationService.location) { _, location in
                if let location { centerMap(location.coordinate) }
            }
            .alert("Адрес", isPresented: Binding(
                get: { searchError != nil || locationService.errorMessage != nil },
                set: { if !$0 { searchError = nil; locationService.errorMessage = nil } }
            )) {
                Button("Понятно", role: .cancel) {
                    searchError = nil
                    locationService.errorMessage = nil
                }
            } message: {
                Text(searchError ?? locationService.errorMessage ?? "")
            }
            .safeAreaInset(edge: .bottom) {
                Text("Передвиньте карту: центр под прицелом станет точкой организации.")
                    .font(.subheadline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .systemBackground))
            }
            .navigationTitle("Точка организации")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Выбрать") {
                        point = candidate
                        dismiss()
                    }
                    .disabled(candidate == nil)
                }
            }
        }
        .onAppear {
            let initial = point ?? .gudermes
            candidate = initial
            position = .region(
                MKCoordinateRegion(
                    center: initial.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                ))
        }
    }

    private func searchAddress() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = search
        do {
            let response = try await MKLocalSearch(request: request).start()
            guard let item = response.mapItems.first else {
                searchError = "Адрес не найден. Попробуйте уточнить запрос."
                return
            }
            centerMap(item.placemark.coordinate)
        } catch {
            searchError = "Не удалось найти адрес: \(error.localizedDescription)"
        }
    }

    private func centerMap(_ coordinate: CLLocationCoordinate2D) {
        position = .region(MKCoordinateRegion(
            center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
}

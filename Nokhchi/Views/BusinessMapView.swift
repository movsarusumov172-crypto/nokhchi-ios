import MapKit
import SwiftUI

struct BusinessMapView: View {
    @Environment(AppStore.self) private var store
    @State private var locationService = LocationService()
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: GeoPoint.gudermes.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    )
    @State private var category: BusinessCategory?
    @State private var selectedID: String?
    @State private var selectedBusiness: Business?
    @State private var selectedDraft: OrganizationDraft?
    @State private var showingSource = false

    private var businesses: [Business] {
        store.businesses.filter { category == nil || $0.category == category }
    }

    private var drafts: [OrganizationDraft] {
        store.state.drafts.filter { category == nil || $0.category == category }
    }

    var body: some View {
        Map(position: $position, selection: $selectedID) {
            UserAnnotation()
            ForEach(businesses) { business in
                if let point = business.cityCenter {
                    Marker(
                        "\(business.name) · центр города",
                        systemImage: business.category.symbol, coordinate: point.coordinate
                    )
                    .tag(business.id)
                }
            }
            ForEach(drafts) { draft in
                if let point = draft.location {
                    Marker(
                        "\(draft.name) · черновик", systemImage: "pencil",
                        coordinate: point.coordinate
                    )
                    .tag(draft.id.uuidString)
                }
            }
        }
        .mapStyle(.standard(elevation: .flat))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            CategoryStrip(selection: $category)
                .background(Color(uiColor: .systemBackground))
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button {
                showingSource = true
            } label: {
                Label("Локальные данные · о точках на карте", systemImage: "info.circle")
                    .font(.footnote)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .background(Color(uiColor: .systemBackground))
        }
        .navigationTitle("Карта")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { mapToolbar }
        .onChange(of: selectedID) { _, identifier in
            guard let identifier else { return }
            selectedBusiness = businesses.first { $0.id == identifier }
            selectedDraft = drafts.first { $0.id.uuidString == identifier }
        }
        .onChange(of: locationService.location) { _, point in
            if let point {
                position = .region(MKCoordinateRegion(
                    center: point.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
                ))
            }
        }
        .sheet(item: $selectedBusiness, onDismiss: { selectedID = nil }) { business in
            NavigationStack {
                BusinessDetailView(business: business)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Готово") { selectedBusiness = nil }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedDraft, onDismiss: { selectedID = nil }) { draft in
            DraftEditorView(draft: draft)
        }
        .sheet(isPresented: $showingSource) { mapInformation }
        .alert("Геопозиция", isPresented: locationError) {
            Button("Понятно", role: .cancel) { locationService.errorMessage = nil }
        } message: {
            Text(locationService.errorMessage ?? "")
        }
    }

    @ToolbarContentBuilder
    private var mapToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button("Гудермес", systemImage: "map") {
                    position = .region(MKCoordinateRegion(
                        center: GeoPoint.gudermes.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                    ))
                }
                Button("Все доступные точки", systemImage: "arrow.up.left.and.arrow.down.right") {
                    position = .automatic
                }
            } label: {
                Label("Регион карты", systemImage: "globe.europe.africa")
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                locationService.requestLocation()
            } label: {
                Label("Моё местоположение", systemImage: "location")
            }
            .disabled(locationService.isRequesting)
        }
    }

    private var mapInformation: some View {
        NavigationStack {
            List {
                Section("Начальный регион — Гудермес") {
                    Text("В материалах нет организаций с подтверждённым адресом в Гудермесе.")
                    Text("Точки каталога обозначают центр указанного города, "
                         + "а не адрес организации. Масштаб карты можно менять жестами.")
                    Button("Показать доступные точки") {
                        position = .automatic
                        showingSource = false
                    }
                }
                Section("Ваши черновики") {
                    Text("На вкладке «Добавить» можно указать точку на карте. "
                         + "Сохранённый черновик появится здесь с подписью «черновик».")
                }
                Section { DemoNotice() }
            }
            .navigationTitle("О карте")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { showingSource = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var locationError: Binding<Bool> {
        Binding(
            get: { locationService.errorMessage != nil },
            set: { if !$0 { locationService.errorMessage = nil } }
        )
    }
}

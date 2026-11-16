import MapKit
import SwiftUI

struct BusinessMapView: View {
    @Binding var selectedTab: Int
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
    @State private var showingNotifications = false

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
        .ignoresSafeArea()
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 4) {
                HStack {
                    Button {
                        selectedTab = 3
                    } label: {
                        ProfileAvatar(
                            name: store.state.userName, data: store.state.avatarData, size: 40)
                    }
                    .accessibilityLabel("Открыть профиль")
                    Spacer()
                    Button {
                        showingNotifications = true
                    } label: {
                        Image(systemName: "bell")
                            .frame(width: 44, height: 44)
                            .background(.regularMaterial, in: Circle())
                    }
                    .accessibilityLabel("Уведомления")
                }
                .padding(.horizontal)
                CategoryStrip(selection: $category)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack(alignment: .bottom) {
                Button {
                    showingSource = true
                } label: {
                    Label("О карте", systemImage: "info.circle")
                        .padding(10)
                        .background(.regularMaterial, in: Capsule())
                }
                Spacer()
                Menu {
                    Button("Гудермес", systemImage: "map") {
                        position = .region(
                            MKCoordinateRegion(
                                center: GeoPoint.gudermes.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                            ))
                    }
                    Button("Все доступные точки", systemImage: "globe") { position = .automatic }
                } label: {
                    Image(systemName: "globe.europe.africa")
                        .frame(width: 44, height: 44)
                        .background(.regularMaterial, in: Circle())
                }
                .accessibilityLabel("Регион карты")
                Button {
                    locationService.requestLocation()
                } label: {
                    Image(systemName: "location.fill")
                        .frame(width: 44, height: 44)
                        .background(.regularMaterial, in: Circle())
                }
                .accessibilityLabel("Моё местоположение")
                .disabled(locationService.isRequesting)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .tabBar)
        .onChange(of: selectedID) { _, identifier in
            guard let identifier else { return }
            selectedBusiness = businesses.first { $0.id == identifier }
            selectedDraft = drafts.first { $0.id.uuidString == identifier }
        }
        .onChange(of: locationService.location) { _, point in
            if let point {
                position = .region(
                    MKCoordinateRegion(
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
        .sheet(isPresented: $showingNotifications) {
            NavigationStack {
                UnavailableFeatureView(
                    title: "Уведомления", symbol: "bell",
                    detail: "Уведомления недоступны: сервер Nokhchi не подключён."
                )
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Готово") { showingNotifications = false }
                    }
                }
            }
        }
        .alert("Геопозиция", isPresented: locationError) {
            Button("Понятно", role: .cancel) { locationService.errorMessage = nil }
        } message: {
            Text(locationService.errorMessage ?? "")
        }
    }

    private var mapInformation: some View {
        NavigationStack {
            List {
                Section("Начальный регион — Гудермес") {
                    Text("В материалах нет организаций с подтверждённым адресом в Гудермесе.")
                    Text(
                        "Точки каталога обозначают центр указанного города, "
                            + "а не адрес организации. Масштаб карты можно менять жестами.")
                    Button("Показать доступные точки") {
                        position = .automatic
                        showingSource = false
                    }
                }
                Section("Ваши черновики") {
                    Text(
                        "На вкладке «Добавить» можно указать точку на карте. "
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

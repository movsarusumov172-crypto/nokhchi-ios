import SwiftUI

struct DraftAddressView: View {
    @Binding var draft: OrganizationDraft
    @State private var showingMap = false

    var body: some View {
        Form {
            Section("Адрес") {
                TextField("Город", text: $draft.city).accessibilityIdentifier("draftCity")
                TextField("Адрес", text: $draft.address, axis: .vertical).lineLimit(2...4)
                Button("Выбрать точку на карте", systemImage: "mappin.and.ellipse") {
                    showingMap = true
                }
                if let point = draft.location {
                    Text("\(point.latitude.formatted()), \(point.longitude.formatted())")
                        .font(.caption).foregroundStyle(.secondary)
                    Button("Удалить точку", role: .destructive) { draft.location = nil }
                }
            } footer: {
                Text("Введите адрес и выберите точку на карте. В поиске используется Apple Maps.")
            }
        }
        .sheet(isPresented: $showingMap) { LocationPickerView(point: $draft.location) }
    }
}

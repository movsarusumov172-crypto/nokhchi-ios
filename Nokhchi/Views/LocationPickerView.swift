import MapKit
import SwiftUI

struct LocationPickerView: View {
    @Binding var point: GeoPoint?
    @State private var candidate: GeoPoint?
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
}

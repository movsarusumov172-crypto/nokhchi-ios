import SwiftUI

struct UnavailableFeatureView: View {
    let title: String
    let symbol: String
    let detail: String

    var body: some View {
        ScrollView {
            ContentUnavailableView(title, systemImage: symbol, description: Text(detail))
                .padding(.top, 32)
            Text("Функция недоступна в прототипе")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

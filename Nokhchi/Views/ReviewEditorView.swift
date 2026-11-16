import SwiftUI

struct ReviewEditorView: View {
    let business: Business
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var rating = 0
    @State private var text = ""
    @State private var personalExperience = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Оценка", selection: $rating) {
                        Text("Выберите оценку").tag(0)
                        ForEach(1...5, id: \.self) { Text("\($0) из 5").tag($0) }
                    }
                    TextField("Ваш отзыв", text: $text, axis: .vertical).lineLimit(5...12)
                    Text("\(text.count)/2000").font(.caption).foregroundStyle(.secondary)
                    Toggle("Отзыв основан на моём личном опыте", isOn: $personalExperience)
                } header: {
                    Text("Оценка")
                } footer: {
                    Text(
                        "Пишите правдиво и справедливо, только о личном опыте. "
                            + "Отзыв сохранится только на этом устройстве.")
                }
            }
            .navigationTitle("Написать отзыв")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        let review = LocalReview(
                            businessID: business.id, author: store.state.userName,
                            rating: rating, text: text)
                        if store.addReview(review) { dismiss() }
                    }
                    .disabled(
                        !personalExperience || rating == 0 || text.count > 2000
                            || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

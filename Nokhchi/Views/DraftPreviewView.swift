import SwiftUI

struct DraftPreviewView: View {
    let draft: OrganizationDraft

    var body: some View {
        List {
            Section {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(Array((draft.photos ?? []).enumerated()), id: \.offset) { _, data in
                            if let image = UIImage(data: data) {
                                Image(uiImage: image).resizable().scaledToFill()
                                    .frame(width: 180, height: 130).clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                Text(draft.name.isEmpty ? "Без названия" : draft.name).font(.title2.bold())
                Label(draft.category.title, systemImage: draft.category.symbol)
                if !draft.city.isEmpty { Label(draft.city, systemImage: "mappin") }
                if !draft.address.isEmpty { Text(draft.address) }
                if !draft.note.isEmpty { Text(draft.note) }
            }
            Section("Публикация") {
                Text(
                    "Это локальный предпросмотр. Отправка на проверку и публикация "
                        + "недоступны без сервера Nokhchi.")
                if let message = draft.validationMessage {
                    Text(message).foregroundStyle(.secondary)
                }
            }
        }
    }
}

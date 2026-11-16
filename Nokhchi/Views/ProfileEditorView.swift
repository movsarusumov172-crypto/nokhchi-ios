import SwiftUI
import PhotosUI

struct ProfileEditorView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var avatarData: Data?
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                Section("Фото профиля") {
                    ProfileAvatar(name: name, data: avatarData, size: 60)
                    PhotosPicker("Выбрать фото", selection: $selectedPhoto, matching: .images)
                    if avatarData != nil {
                        Button("Удалить фото", role: .destructive) { avatarData = nil }
                    }
                }
                Section {
                    TextField("Имя", text: $name).textContentType(.name)
                } footer: {
                    Text("До 80 символов. Изменения сохраняются только на этом iPhone.")
                }
                if let message = store.errorMessage {
                    Section { Text(message).foregroundStyle(.red) }
                }
            }
            .navigationTitle("Имя пользователя")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        if store.setProfile(name: name, avatarData: avatarData) { dismiss() }
                    }
                    .disabled(
                        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            || name.count > 80)
                }
            }
        }
        .onAppear {
            name = store.state.userName
            avatarData = store.state.avatarData
        }
        .onChange(of: selectedPhoto) { _, photo in
            Task {
                do {
                    guard let data = try await photo?.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else {
                        store.errorMessage = "Не удалось прочитать выбранное фото."
                        return
                    }
                    let size = CGSize(width: 256, height: 256)
                    let renderer = UIGraphicsImageRenderer(size: size)
                    let scale = max(size.width / image.size.width, size.height / image.size.height)
                    let imageSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                    let origin = CGPoint(
                        x: (size.width - imageSize.width) / 2,
                        y: (size.height - imageSize.height) / 2
                    )
                    let thumbnail = renderer.image { _ in
                        image.draw(in: CGRect(origin: origin, size: imageSize))
                    }
                    guard let jpeg = thumbnail.jpegData(compressionQuality: 0.8) else {
                        store.errorMessage = "Не удалось подготовить фото профиля."
                        return
                    }
                    avatarData = jpeg
                } catch {
                    store.errorMessage = "Не удалось загрузить фото: \(error.localizedDescription)"
                }
            }
        }
    }
}

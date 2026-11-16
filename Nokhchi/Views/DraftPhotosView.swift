import PhotosUI
import SwiftUI

struct DraftPhotosView: View {
    @Binding var draft: OrganizationDraft
    @Binding var loading: Bool
    @State private var selection: [PhotosPickerItem] = []
    @State private var errorMessage: String?
    @State private var loadingTask: Task<Void, Never>?

    var body: some View {
        Form {
            Section {
                PhotosPicker(
                    selection: $selection, maxSelectionCount: DraftMediaLimits.maximumPhotos,
                    matching: .images
                ) {
                    Label("Выбрать фотографии", systemImage: "photo.on.rectangle.angled")
                }
                if loading { ProgressView("Загрузка фотографий") }
                if let errorMessage { Text(errorMessage).foregroundStyle(.red) }
                ForEach(Array((draft.photos ?? []).enumerated()), id: \.offset) { index, data in
                    HStack {
                        if let image = UIImage(data: data) {
                            Image(uiImage: image).resizable().scaledToFill()
                                .frame(width: 56, height: 56).clipped().accessibilityHidden(true)
                        }
                        Text("Фото \(index + 1)")
                        Spacer()
                        Button("Удалить", role: .destructive) { draft.photos?.remove(at: index) }
                    }
                }
            } header: {
                Text("Фотографии")
            } footer: {
                Text(
                    "На снимке для публикации требуется от 3 до 10 фото, "
                        + "минимум 1080 пикселей по короткой стороне. Черновик сохраняется и без них."
                )
            }
            Section("Пример: что снять") {
                Text("Для IT и дизайна: проекты, рабочее место, портфолио или логотип.")
            }
        }
        .onChange(of: selection) { _, items in
            let previous = loadingTask
            previous?.cancel()
            loadingTask = Task {
                await previous?.value
                guard !Task.isCancelled else { return }
                await loadPhotos(items)
            }
        }
        .onDisappear { loadingTask?.cancel() }
    }

    private func loadPhotos(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        loading = true
        defer { loading = false }
        do {
            var photos: [Data] = []
            for item in items {
                try Task.checkCancellation()
                guard let data = try await item.loadTransferable(type: Data.self),
                    let image = UIImage(data: data),
                    let pixels = image.cgImage,
                    min(pixels.width, pixels.height) >= DraftMediaLimits.minimumPhotoPixels,
                    let jpeg = image.jpegData(compressionQuality: 0.7),
                    jpeg.count <= DraftMediaLimits.maximumPhotoBytes
                else {
                    errorMessage =
                        "Фото должно быть не меньше 1080 пикселей по короткой стороне и до 3 МБ после сжатия."
                    return
                }
                photos.append(jpeg)
            }
            try Task.checkCancellation()
            draft.photos = photos
            errorMessage = nil
        } catch is CancellationError {
            return
        } catch {
            errorMessage = "Не удалось загрузить фотографии: \(error.localizedDescription)"
        }
    }
}

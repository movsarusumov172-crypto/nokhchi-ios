import AVKit
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct DraftVideoView: View {
    @Binding var draft: OrganizationDraft
    let originalVideo: String?
    @Binding var loading: Bool
    @Environment(AppStore.self) private var store
    @State private var showingPicker = false
    @State private var errorMessage: String?
    @State private var importTask: Task<Void, Never>?
    @State private var selectedVideo: PhotosPickerItem?

    var body: some View {
        Form {
            Section {
                PhotosPicker("Выбрать видео из Фото", selection: $selectedVideo, matching: .videos)
                    .disabled(loading)
                Button("Выбрать видео в Файлах", systemImage: "video.badge.plus") {
                    showingPicker = true
                }
                .disabled(loading)
                if loading { ProgressView("Проверка видео") }
                if let errorMessage { Text(errorMessage).foregroundStyle(.red) }
                if let filename = draft.videoFile, let url = store.videoURL(filename) {
                    VideoPlayer(player: AVPlayer(url: url)).frame(height: 220)
                    Button("Удалить видео", role: .destructive) {
                        if filename != originalVideo { store.removeVideo(filename) }
                        draft.videoFile = nil
                    }
                }
            } header: {
                Text("Видео — необязательно")
            } footer: {
                Text(
                    "На снимке указаны 5–60 секунд и минимум 720 пикселей. "
                        + "Файл хранится локально и не сжимается автоматически.")
            }
            Section("Пример: что снять") {
                Text("Для IT и дизайна: короткая демонстрация готового проекта на экране.")
            }
        }
        .fileImporter(isPresented: $showingPicker, allowedContentTypes: [.movie]) { result in
            switch result {
            case .success(let url):
                importTask?.cancel()
                importTask = Task { await importVideo(url) }
            case .failure(let error):
                errorMessage = "Не удалось выбрать видео: \(error.localizedDescription)"
            }
        }
        .onChange(of: selectedVideo) { _, item in
            guard let item else { return }
            importTask?.cancel()
            importTask = Task { await importPhotoVideo(item) }
        }
        .onDisappear { importTask?.cancel() }
    }

    private func importPhotoVideo(_ item: PhotosPickerItem) async {
        loading = true
        defer {
            loading = false
            selectedVideo = nil
        }
        do {
            guard let video = try await item.loadTransferable(type: TemporaryVideo.self) else {
                errorMessage = "Не удалось получить выбранное видео."
                return
            }
            defer {
                do {
                    try FileManager.default.removeItem(at: video.url)
                } catch {
                    store.errorMessage =
                        "Не удалось удалить временное видео: "
                        + error.localizedDescription
                }
            }
            try Task.checkCancellation()
            await importVideo(video.url)
        } catch is CancellationError {
            return
        } catch {
            errorMessage = "Не удалось загрузить видео из Фото: \(error.localizedDescription)"
        }
    }

    private func importVideo(_ url: URL) async {
        loading = true
        defer { loading = false }
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }
        do {
            let asset = AVURLAsset(url: url)
            let duration = try await asset.load(.duration).seconds
            guard let track = try await asset.loadTracks(withMediaType: .video).first else {
                errorMessage = "В файле нет видеодорожки."
                return
            }
            let size = try await track.load(.naturalSize)
            guard duration.isFinite, DraftMediaLimits.videoDuration.contains(duration),
                min(abs(size.width), abs(size.height)) >= DraftMediaLimits.minimumVideoPixels
            else {
                errorMessage = "Видео должно длиться 5–60 секунд и иметь разрешение не менее 720p."
                return
            }
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            guard let fileSize = attributes[.size] as? NSNumber,
                fileSize.intValue <= DraftMediaLimits.maximumVideoBytes
            else {
                errorMessage = "Размер видео не должен превышать 200 МБ."
                return
            }
            try Task.checkCancellation()
            let filename = try store.importVideo(from: url)
            if let old = draft.videoFile, old != originalVideo { store.removeVideo(old) }
            draft.videoFile = filename
            errorMessage = nil
        } catch is CancellationError {
            return
        } catch {
            errorMessage = "Не удалось сохранить видео: \(error.localizedDescription)"
        }
    }
}

private struct TemporaryVideo: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .movie) { file in
            let attributes = try FileManager.default.attributesOfItem(atPath: file.file.path)
            guard let size = attributes[.size] as? NSNumber,
                size.intValue <= DraftMediaLimits.maximumVideoBytes
            else {
                throw VideoImportError.tooLarge
            }
            let destination = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(file.file.pathExtension)
            try FileManager.default.copyItem(at: file.file, to: destination)
            return TemporaryVideo(url: destination)
        }
    }
}

private enum VideoImportError: LocalizedError {
    case tooLarge

    var errorDescription: String? { "Размер видео не должен превышать 200 МБ." }
}

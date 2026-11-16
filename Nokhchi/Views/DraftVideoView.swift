import AVKit
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

    var body: some View {
        Form {
            Section {
                Button("Выбрать видео в Файлах", systemImage: "video.badge.plus") {
                    showingPicker = true
                }
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
                Text("На снимке указаны 5–60 секунд и минимум 720 пикселей. "
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
        .onDisappear { importTask?.cancel() }
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
            guard duration.isFinite, (5...60).contains(duration),
                  min(abs(size.width), abs(size.height)) >= 720 else {
                errorMessage = "Видео должно длиться 5–60 секунд и иметь разрешение не менее 720p."
                return
            }
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            guard let fileSize = attributes[.size] as? NSNumber, fileSize.intValue <= 200_000_000 else {
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

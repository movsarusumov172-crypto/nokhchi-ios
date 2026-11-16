import Foundation
import Observation

@MainActor
@Observable
final class AppStore {
    private(set) var businesses: [Business] = []
    private(set) var state = LocalState()
    var errorMessage: String?
    private let stateURL: URL
    private var canSave = true

    init(directory: URL? = nil, loadCatalog: Bool = true) {
        let base = directory ?? URL.documentsDirectory.appendingPathComponent("Nokhchi")
        stateURL = base.appendingPathComponent("local-state.json")
        if loadCatalog { readCatalog() }
        readState()
    }

    var cities: [String] {
        Set(businesses.compactMap(\.city)).sorted()
    }

    func setAppearance(_ appearance: Appearance) {
        var next = state
        next.appearance = appearance
        save(next)
    }

    func setNotifications(_ enabled: Bool) {
        var next = state
        next.notificationsEnabled = enabled
        save(next)
    }

    func setUserName(_ name: String) {
        var next = state
        next.userName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        save(next)
    }

    func setProfile(name: String, avatarData: Data?) -> Bool {
        var next = state
        next.userName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        next.avatarData = avatarData
        return save(next)
    }

    func toggleFavorite(_ business: Business) {
        var next = state
        if next.favorites.contains(business.id) {
            next.favorites.remove(business.id)
        } else {
            next.favorites.insert(business.id)
        }
        save(next)
    }

    @discardableResult
    func saveDraft(_ draft: OrganizationDraft) -> Bool {
        if let message = draft.validationMessage {
            errorMessage = message
            return false
        }
        var next = state
        var updated = draft
        updated.updatedAt = Date()
        let previousVideo = next.drafts.first { $0.id == draft.id }?.videoFile
        if let index = next.drafts.firstIndex(where: { $0.id == draft.id }) {
            next.drafts[index] = updated
        } else {
            next.drafts.insert(updated, at: 0)
        }
        guard save(next) else { return false }
        if let previousVideo, previousVideo != draft.videoFile { removeVideo(previousVideo) }
        return true
    }

    func deleteDraft(_ draft: OrganizationDraft) {
        var next = state
        next.drafts.removeAll { $0.id == draft.id }
        if save(next), let video = draft.videoFile { removeVideo(video) }
    }

    func videoURL(_ filename: String) -> URL? {
        guard filename == URL(fileURLWithPath: filename).lastPathComponent else { return nil }
        return stateURL.deletingLastPathComponent().appendingPathComponent("Videos")
            .appendingPathComponent(filename)
    }

    func importVideo(from source: URL) throws -> String {
        let filename = UUID().uuidString + ".mov"
        guard let destination = videoURL(filename) else { throw StoreError.invalidData }
        try FileManager.default.createDirectory(
            at: destination.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        try FileManager.default.copyItem(at: source, to: destination)
        return filename
    }

    func removeVideo(_ filename: String) {
        guard let url = videoURL(filename), FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            errorMessage = "Не удалось удалить локальное видео: \(error.localizedDescription)"
        }
    }

    func addReview(_ review: LocalReview) -> Bool {
        guard (1...5).contains(review.rating),
            !review.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            review.text.count <= 2000
        else {
            errorMessage = "Укажите оценку и текст отзыва до 2000 символов."
            return false
        }
        var next = state
        if next.reviews == nil { next.reviews = [] }
        next.reviews?.append(review)
        return save(next)
    }

    private func readCatalog() {
        do {
            guard let url = Bundle.main.url(forResource: "businesses", withExtension: "json") else {
                throw StoreError.missingCatalog
            }
            let decoded = try JSONDecoder().decode([Business].self, from: Data(contentsOf: url))
            let hasUniqueIdentifiers = Set(decoded.map(\.id)).count == decoded.count
            guard decoded.allSatisfy(\.isValid), hasUniqueIdentifiers else {
                throw StoreError.invalidData
            }
            businesses = decoded
        } catch {
            errorMessage = "Не удалось прочитать локальный каталог: \(error.localizedDescription)"
        }
    }

    private func readState() {
        guard FileManager.default.fileExists(atPath: stateURL.path) else { return }
        do {
            let data = try Data(contentsOf: stateURL)
            let decoded = try JSONDecoder().decode(LocalState.self, from: data)
            guard decoded.isValid else { throw StoreError.invalidData }
            state = decoded
        } catch {
            canSave = false
            errorMessage =
                "Локальные данные повреждены или недоступны. "
                + "Исходный файл сохранён; запись отключена. \(error.localizedDescription)"
        }
    }

    @discardableResult
    private func save(_ next: LocalState) -> Bool {
        guard canSave else {
            errorMessage =
                "Запись отключена, чтобы не перезаписать повреждённые данные. "
                + "Сохраните local-state.json через Files и переустановите приложение."
            return false
        }
        guard next.isValid else {
            errorMessage = "Не удалось сохранить данные: проверьте заполненные поля."
            return false
        }
        do {
            try FileManager.default.createDirectory(
                at: stateURL.deletingLastPathComponent(), withIntermediateDirectories: true
            )
            let data = try JSONEncoder().encode(next)
            try data.write(to: stateURL, options: [.atomic, .completeFileProtection])
            state = next
            return true
        } catch {
            errorMessage = "Не удалось сохранить локальные изменения: \(error.localizedDescription)"
            return false
        }
    }
}

private enum StoreError: LocalizedError {
    case missingCatalog
    case invalidData

    var errorDescription: String? {
        switch self {
        case .missingCatalog: "Файл businesses.json отсутствует в приложении."
        case .invalidData: "Формат или значения данных некорректны."
        }
    }
}

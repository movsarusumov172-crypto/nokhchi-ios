import Foundation

enum DraftMediaLimits {
    static let maximumPhotos = 10
    static let minimumPhotoPixels = 1080
    static let maximumPhotoBytes = 3_000_000
    static let minimumVideoPixels: CGFloat = 720
    static let videoDuration = 5.0...60.0
    static let maximumVideoBytes = 200_000_000
}

enum Appearance: String, CaseIterable, Codable, Identifiable {
    case system = "Как в системе"
    case light = "Светлая"
    case dark = "Тёмная"
    var id: String { rawValue }
}

struct OrganizationDraft: Codable, Identifiable, Equatable {
    var id = UUID()
    var category: BusinessCategory
    var name = ""
    var city = ""
    var address = ""
    var note = ""
    var location: GeoPoint?
    var updatedAt = Date()
    var phone: String?
    var whatsapp: String?
    var telegram: String?
    var instagram: String?
    var website: String?
    var languages: [String]?
    var photos: [Data]?
    var videoFile: String?
    var alwaysOpen: Bool?
    var openingTime: String?
    var closingTime: String?

    var validationMessage: String? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Укажите название организации."
        }
        if city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Укажите город."
        }
        if name.count > 120 || city.count > 100 || address.count > 250 || note.count > 2000 {
            return "Сократите название, город, адрес или описание до указанных ограничений."
        }
        if let photos,
            photos.count > DraftMediaLimits.maximumPhotos
                || photos.contains(where: { $0.count > DraftMediaLimits.maximumPhotoBytes })
        {
            return "Допускается до 10 фотографий размером до 3 МБ каждая."
        }
        if let videoFile, videoFile != URL(fileURLWithPath: videoFile).lastPathComponent {
            return "Имя видеофайла некорректно."
        }
        if let location, !location.isValid {
            return "Координаты точки некорректны. Выберите точку заново."
        }
        return nil
    }
}

struct LocalReview: Codable, Identifiable {
    var id = UUID()
    var businessID: String
    var author: String
    var rating: Int
    var text: String
    var createdAt = Date()
}

struct LocalState: Codable {
    var appearance: Appearance = .dark
    var notificationsEnabled = false
    var userName = "Мовсар Усумов"
    var avatarData: Data?
    var favorites: Set<String> = []
    var drafts: [OrganizationDraft] = []
    var reviews: [LocalReview]?

    var isValid: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && userName.count <= 80
            && (avatarData.map { $0.count <= 1_000_000 } ?? true)
            && drafts.allSatisfy { $0.validationMessage == nil }
            && Set(drafts.map(\.id)).count == drafts.count
            && (reviews?.allSatisfy { (1...5).contains($0.rating) && !$0.text.isEmpty } ?? true)
    }
}

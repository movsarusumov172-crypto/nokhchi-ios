import Foundation

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
        if let location, !location.isValid {
            return "Координаты точки некорректны. Выберите точку заново."
        }
        return nil
    }
}

struct LocalState: Codable {
    var appearance: Appearance = .dark
    var notificationsEnabled = false
    var userName = "Мовсар Усумов"
    var favorites: Set<String> = []
    var drafts: [OrganizationDraft] = []

    var isValid: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && userName.count <= 80
            && drafts.allSatisfy { $0.validationMessage == nil }
            && Set(drafts.map(\.id)).count == drafts.count
    }
}

import Foundation

struct GeoPoint: Codable, Equatable, Hashable {
    var latitude: Double
    var longitude: Double

    var isValid: Bool {
        latitude.isFinite && longitude.isFinite
            && (-90...90).contains(latitude) && (-180...180).contains(longitude)
    }
}

struct Business: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let category: BusinessCategory
    let city: String?
    let rating: Double?
    let reviewCount: Int?
    let photo: String
    let cityCenter: GeoPoint?

    var isValid: Bool {
        !id.isEmpty && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (rating.map { $0.isFinite && (0...5).contains($0) } ?? true)
            && (reviewCount.map { $0 >= 0 } ?? true)
            && (cityCenter.map(\.isValid) ?? true)
            && !photo.isEmpty
    }
}

enum BusinessSort: String, CaseIterable, Identifiable {
    case rating = "По рейтингу"
    case name = "По названию"
    var id: String { rawValue }
}

struct CatalogQuery {
    var text = ""
    var category: BusinessCategory?
    var city: String?
    var favoritesOnly = false
    var sort: BusinessSort = .rating

    func apply(to businesses: [Business], favorites: Set<String>) -> [Business] {
        businesses.filter { business in
            let searchable = [business.name, business.category.title, business.city ?? ""]
                .joined(separator: " ")
            let searchMatches = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || searchable.localizedStandardContains(
                    text.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            return searchMatches && (category == nil || category == business.category)
                && (city == nil || city == business.city)
                && (!favoritesOnly || favorites.contains(business.id))
        }.sorted { first, second in
            if sort == .rating, first.rating != second.rating {
                return (first.rating ?? -1) > (second.rating ?? -1)
            }
            return first.name.localizedStandardCompare(second.name) == .orderedAscending
        }
    }
}

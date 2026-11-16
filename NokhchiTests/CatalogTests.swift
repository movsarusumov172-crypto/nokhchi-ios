import XCTest

@testable import Nokhchi

final class CatalogTests: XCTestCase {
    private let restaurant = Business(
        id: "restaurant", name: "КАРАК", category: .restaurants, city: "Москва",
        rating: 5, reviewCount: 1, photo: "karak", cityCenter: nil
    )
    private let shop = Business(
        id: "shop", name: "Магазин парфюмерии и масла", category: .halal, city: "Берлин",
        rating: nil, reviewCount: nil, photo: "perfume", cityCenter: nil
    )

    func testSearchMatchesNameCityAndCategoryIgnoringCase() {
        for search in ["кара", "МОСКВА", "Рестораны", "  Москва  "] {
            var query = CatalogQuery()
            query.text = search
            XCTAssertEqual(
                query.apply(to: [restaurant, shop], favorites: []).map(\.id),
                [restaurant.id])
        }
    }

    func testFiltersIntersectAndCanProduceEmptyResults() {
        var query = CatalogQuery()
        query.category = .restaurants
        query.city = "Берлин"
        XCTAssertTrue(query.apply(to: [restaurant, shop], favorites: []).isEmpty)
        query.city = "Москва"
        query.favoritesOnly = true
        XCTAssertTrue(query.apply(to: [restaurant, shop], favorites: []).isEmpty)
        XCTAssertEqual(query.apply(to: [restaurant, shop], favorites: [restaurant.id]).count, 1)
    }

    func testMissingRatingComesAfterKnownRating() {
        XCTAssertEqual(
            CatalogQuery().apply(to: [shop, restaurant], favorites: []).first?.id,
            restaurant.id)
    }

    func testDraftRequiresNameAndCityAndValidCoordinates() {
        var draft = OrganizationDraft(category: .restaurants)
        XCTAssertNotNil(draft.validationMessage)
        draft.name = "Мой черновик"
        XCTAssertNotNil(draft.validationMessage)
        draft.city = "Гудермес"
        XCTAssertNil(draft.validationMessage)
        draft.location = GeoPoint(latitude: 91, longitude: 0)
        XCTAssertNotNil(draft.validationMessage)
        draft.location = GeoPoint(latitude: 43, longitude: 46)
        draft.name = String(repeating: "a", count: 121)
        XCTAssertNotNil(draft.validationMessage)
    }

    func testInvalidExternalValuesAreRejected() {
        XCTAssertFalse(GeoPoint(latitude: .nan, longitude: 0).isValid)
        XCTAssertFalse(GeoPoint(latitude: 0, longitude: .infinity).isValid)
        XCTAssertFalse(GeoPoint(latitude: 0, longitude: 181).isValid)
    }
}

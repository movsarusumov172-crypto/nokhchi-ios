import XCTest

@testable import Nokhchi

final class PersistenceTests: XCTestCase {
    @MainActor
    func testFavoriteAppearanceProfileAndDraftSurviveReload() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        addDirectoryCleanup(directory)
        let store = AppStore(directory: directory)
        XCTAssertNil(store.errorMessage)
        let business = try XCTUnwrap(store.businesses.first)
        store.toggleFavorite(business)
        store.setAppearance(.light)
        store.setUserName("Локальное имя")
        XCTAssertTrue(store.setProfile(name: "Локальное имя", avatarData: Data([1, 2, 3])))
        store.setNotifications(true)
        var draft = OrganizationDraft(category: .autoService)
        draft.name = "Мой черновик"
        draft.city = "Гудермес"
        draft.location = GeoPoint(latitude: 43.35, longitude: 46.10)
        XCTAssertTrue(store.saveDraft(draft))

        let reloaded = AppStore(directory: directory)
        XCTAssertTrue(reloaded.state.favorites.contains(business.id))
        XCTAssertEqual(reloaded.state.appearance, .light)
        XCTAssertEqual(reloaded.state.userName, "Локальное имя")
        XCTAssertEqual(reloaded.state.avatarData, Data([1, 2, 3]))
        XCTAssertTrue(reloaded.state.notificationsEnabled)
        XCTAssertEqual(reloaded.state.drafts.first?.location, draft.location)

        draft.name = "Исправленное название"
        XCTAssertTrue(reloaded.saveDraft(draft))
        XCTAssertEqual(reloaded.state.drafts.count, 1)
        XCTAssertEqual(reloaded.state.drafts.first?.name, draft.name)
        reloaded.deleteDraft(draft)
        XCTAssertTrue(AppStore(directory: directory).state.drafts.isEmpty)
    }

    @MainActor
    func testCorruptedStateIsReportedAndNeverOverwritten() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        addDirectoryCleanup(directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let stateURL = directory.appendingPathComponent("local-state.json")
        let corrupted = Data("not-json".utf8)
        try corrupted.write(to: stateURL)
        let store = AppStore(directory: directory, loadCatalog: false)
        XCTAssertNotNil(store.errorMessage)
        store.setAppearance(.light)
        XCTAssertNotNil(store.errorMessage)
        XCTAssertEqual(try Data(contentsOf: stateURL), corrupted)
    }

    @MainActor
    func testRejectedDraftDoesNotChangeState() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        addDirectoryCleanup(directory)
        let store = AppStore(directory: directory, loadCatalog: false)
        XCTAssertFalse(store.saveDraft(OrganizationDraft(category: .medicine)))
        XCTAssertTrue(store.state.drafts.isEmpty)
        XCTAssertNotNil(store.errorMessage)
    }

    @MainActor
    func testBundledCatalogContainsOnlyScreenshotEntries() {
        let store = AppStore(
            directory: FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString))
        XCTAssertNil(store.errorMessage)
        XCTAssertEqual(store.businesses.count, 4)
        XCTAssertTrue(store.businesses.allSatisfy(\.isValid))
        XCTAssertEqual(store.businesses.filter { $0.cityCenter != nil }.count, 3)
        XCTAssertNil(store.businesses.first { $0.id == "screenshot-ozon" }?.rating)
    }

    private func addDirectoryCleanup(_ directory: URL) {
        addTeardownBlock {
            if FileManager.default.fileExists(atPath: directory.path) {
                try FileManager.default.removeItem(at: directory)
            }
        }
    }
}

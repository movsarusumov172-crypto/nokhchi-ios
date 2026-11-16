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

    @MainActor
    func testExpandedDraftAndReviewSurviveReload() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        addDirectoryCleanup(directory)
        let store = AppStore(directory: directory, loadCatalog: false)
        var draft = OrganizationDraft(category: .technology)
        draft.name = "Разработчик"
        draft.city = "Гудермес"
        draft.phone = "+70000000000"
        draft.languages = ["Русский", "English"]
        draft.photos = [Data([1, 2, 3])]
        draft.alwaysOpen = true
        XCTAssertTrue(store.saveDraft(draft))
        let review = LocalReview(businessID: "example", author: "Участник", rating: 4,
                                 text: "Личный опыт")
        XCTAssertTrue(store.addReview(review))
        let reloaded = AppStore(directory: directory, loadCatalog: false)
        XCTAssertEqual(reloaded.state.drafts.first?.languages, ["Русский", "English"])
        XCTAssertEqual(reloaded.state.drafts.first?.photos, [Data([1, 2, 3])])
        XCTAssertEqual(reloaded.state.drafts.first?.alwaysOpen, true)
        XCTAssertEqual(reloaded.state.reviews?.first?.text, "Личный опыт")
    }

    @MainActor
    func testVideoFileIsRemovedWithDraft() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        addDirectoryCleanup(directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let source = directory.appendingPathComponent("source.mov")
        try Data([1, 2, 3]).write(to: source)
        let store = AppStore(directory: directory, loadCatalog: false)
        let filename = try store.importVideo(from: source)
        let savedURL = try XCTUnwrap(store.videoURL(filename))
        var draft = OrganizationDraft(category: .technology)
        draft.name = "Разработчик"
        draft.city = "Гудермес"
        draft.videoFile = filename
        XCTAssertTrue(store.saveDraft(draft))
        XCTAssertTrue(FileManager.default.fileExists(atPath: savedURL.path))
        store.deleteDraft(draft)
        XCTAssertFalse(FileManager.default.fileExists(atPath: savedURL.path))
    }

    @MainActor
    func testOldSavedStateLoadsWithoutNewFields() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        addDirectoryCleanup(directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let oldState = """
            {"appearance":"Тёмная","notificationsEnabled":false,
             "userName":"Участник","favorites":[],"drafts":[]}
            """
        try Data(oldState.utf8).write(to: directory.appendingPathComponent("local-state.json"))
        let store = AppStore(directory: directory, loadCatalog: false)
        XCTAssertNil(store.errorMessage)
        XCTAssertEqual(store.state.userName, "Участник")
        XCTAssertTrue(store.state.drafts.isEmpty)
        XCTAssertNil(store.state.reviews)
    }

    private func addDirectoryCleanup(_ directory: URL) {
        addTeardownBlock {
            if FileManager.default.fileExists(atPath: directory.path) {
                try FileManager.default.removeItem(at: directory)
            }
        }
    }
}

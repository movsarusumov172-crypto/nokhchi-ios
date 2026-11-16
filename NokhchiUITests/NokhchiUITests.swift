import XCTest

final class NokhchiUITests: XCTestCase {
    @MainActor
    func testTabsSearchDetailAndCategoryForm() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["Карта"].waitForExistence(timeout: 10))
        capture("01-map", app: app)
        app.tabBars.buttons["Обзор"].tap()
        XCTAssertTrue(app.searchFields.firstMatch.waitForExistence(timeout: 5))
        capture("02-explore", app: app)
        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText("КАРАК")
        let business = app.cells.containing(.staticText, identifier: "КАРАК").firstMatch
        XCTAssertTrue(business.waitForExistence(timeout: 5))
        business.tap()
        XCTAssertTrue(
            app.buttons["В избранное"].exists || app.buttons["Убрать из избранного"].exists
        )
        capture("03-business", app: app)

        app.tabBars.buttons["Добавить"].tap()
        XCTAssertFalse(app.buttons["Далее"].isEnabled)
        app.buttons["Рестораны и кафе"].tap()
        XCTAssertTrue(app.buttons["Далее"].isEnabled)
        capture("04-categories", app: app)
        app.buttons["Далее"].tap()
        XCTAssertTrue(app.textFields["draftName"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Сохранить"].isEnabled)
        capture("05-draft", app: app)
        app.buttons["Отмена"].tap()

        app.tabBars.buttons["Профиль"].tap()
        XCTAssertTrue(app.staticTexts["Мои бизнесы"].waitForExistence(timeout: 5))
        capture("06-profile", app: app)
    }

    @MainActor
    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

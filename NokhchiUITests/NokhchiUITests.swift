import XCTest

final class NokhchiUITests: XCTestCase {
    @MainActor
    func testTabsSearchDetailAndCategoryForm() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["Карта"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Обзор"].tap()
        XCTAssertTrue(app.searchFields.firstMatch.waitForExistence(timeout: 5))
        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText("КАРАК")
        let business = app.cells.containing(.staticText, identifier: "КАРАК").firstMatch
        XCTAssertTrue(business.waitForExistence(timeout: 5))
        business.tap()
        for _ in 0..<4 {
            if app.buttons["В избранное"].exists || app.buttons["Убрать из избранного"].exists {
                break
            }
            app.swipeUp()
        }
        XCTAssertTrue(
            app.buttons["В избранное"].exists || app.buttons["Убрать из избранного"].exists
        )

        app.tabBars.buttons["Добавить"].tap()
        XCTAssertFalse(app.buttons["Далее"].isEnabled)
        app.buttons["Рестораны и кафе"].tap()
        XCTAssertTrue(app.buttons["Далее"].isEnabled)
        app.buttons["Далее"].tap()
        XCTAssertTrue(app.textFields["draftName"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Сохранить"].isEnabled)
        app.buttons["Далее"].tap()
        XCTAssertTrue(app.buttons["Выбрать фотографии"].waitForExistence(timeout: 5))
        app.buttons["Далее"].tap()
        XCTAssertTrue(app.buttons["Выбрать видео в Файлах"].waitForExistence(timeout: 5))
        app.buttons["Далее"].tap()
        XCTAssertTrue(app.textFields["draftCity"].waitForExistence(timeout: 5))
        app.buttons["Далее"].tap()
        XCTAssertTrue(app.switches["Круглосуточно"].waitForExistence(timeout: 5))
        app.buttons["Далее"].tap()
        XCTAssertTrue(app.buttons["Сохранить черновик"].waitForExistence(timeout: 5))
        app.buttons["Отмена"].tap()
        if app.buttons["Не сохранять"].waitForExistence(timeout: 2) {
            app.buttons["Не сохранять"].tap()
        }

        app.tabBars.buttons["Профиль"].tap()
        XCTAssertTrue(app.staticTexts["Мои бизнесы"].waitForExistence(timeout: 5))
    }
}

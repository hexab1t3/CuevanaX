//
//  CuevanaUITests.swift
//  CuevanaUITests
//
//  Created by Fernando Miranda  on 27/09/26.
//

import XCTest

final class CuevanaUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Con correo y contraseña escritos, el login entra a la app y se ve la barra de pestañas.
    @MainActor
    func testLoginShowsMovies() throws {
        let app = XCUIApplication()
        app.launch()

        // El login rechaza campos vacíos, así que primero se escriben las credenciales
        let mailField = app.textFields["Correo electrónico"]
        XCTAssertTrue(mailField.waitForExistence(timeout: 5))
        mailField.tap()
        mailField.typeText("leo@cuevana.com")

        let passwordField = app.secureTextFields["Contraseña"]
        passwordField.tap()
        passwordField.typeText("1234")

        app.buttons["Iniciar Sesión"].tap()

        // Se revisa la barra de pestañas y no el título de Películas: sin token o sin internet
        // la pantalla muestra el error en lugar del título, pero el login sí funcionó.
        XCTAssertTrue(app.tabBars.buttons["Perfil"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Iniciar Sesión"].exists)
    }

    // Con los campos vacíos el login no entra y muestra el mensaje de error.
    @MainActor
    func testLoginWithEmptyFieldsShowsError() throws {
        let app = XCUIApplication()
        app.launch()

        let loginButton = app.buttons["Iniciar Sesión"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        let errorText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Credenciales inválidas")).firstMatch
        XCTAssertTrue(errorText.waitForExistence(timeout: 3))
        XCTAssertTrue(loginButton.exists, "Debe seguir en la pantalla de login")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

//
//  CuevanaTests.swift
//  CuevanaTests
//

import XCTest
@testable import Cuevana

// Pruebas para la persistencia de la colección con SwiftData
@MainActor
final class FavoritesSwiftDataTests: XCTestCase {

    private func makeStore() -> FavoritesStore {
        FavoritesStore(container: FavoritesStore.inMemoryContainer())
    }

    // Caso normal: guardar una película y comprobar que se guarde bien
    func testAddAndRetrieveFavoriteMovieNormalCase() {
        let store = makeStore()
        let movie = ExampleMovies[0]

        XCTAssertFalse(store.isFavorite(movie), "No debería ser favorita al inicio")
        store.add(movie)

        XCTAssertTrue(store.isFavorite(movie), "Debe estar marcada como favorita")
        XCTAssertEqual(store.items.count, 1, "Debe haber exactamente 1 película guardada")
        XCTAssertEqual(store.items.first?.title, movie.title, "El título guardado debe ser igual")
        XCTAssertEqual(store.items.first?.qualification, movie.qualification, "La calificación debe ser igual")
    }

    // Caso límite: intentar guardar la misma película dos veces y luego eliminarla
    func testPreventDuplicateMovieEdgeCase() {
        let store = makeStore()
        let movie = ExampleMovies[1]

        // Guardamos por primera vez
        store.add(movie)
        XCTAssertEqual(store.items.count, 1)

        // Intentamos guardar la misma película otra vez
        store.add(movie)
        XCTAssertEqual(store.items.count, 1, "No debe duplicar una película que ya existe")

        // Eliminamos la película
        store.remove(movie)
        XCTAssertFalse(store.isFavorite(movie), "Ya no debe estar en favoritos")
        XCTAssertEqual(store.items.count, 0, "La lista debe quedar vacía")
    }

    // Caso sin resultados: consultar una película en una lista vacía
    func testQueryNonExistentMovieEmptyCase() {
        let store = makeStore()
        let movie = ExampleMovies[2]

        XCTAssertFalse(store.isFavorite(movie), "Una película no guardada debe dar false")
        XCTAssertTrue(store.allFavoriteMovies().isEmpty, "La lista de favoritos debe estar vacía")
        XCTAssertEqual(store.ids.count, 0, "No debe haber IDs guardados")
    }
}

// Pruebas para la búsqueda y filtrado de películas
@MainActor
final class SearchMovieTests: XCTestCase {

    // Caso normal: búsqueda por nombre
    func testSearchNormalQuery() {
        let viewModel = FindViewModel()
        viewModel.searchText = "Batman"

        XCTAssertEqual(viewModel.filteredMovies.count, 1, "Debe encontrar una película")
        XCTAssertEqual(viewModel.filteredMovies.first?.title, "The Batman")
    }

    // Caso límite: búsqueda con mayúsculas y espacios extras
    func testSearchCaseInsensitiveAndWhitespaceEdgeCase() {
        let viewModel = FindViewModel()
        viewModel.searchText = "   bAtMaN   "

        XCTAssertEqual(viewModel.filteredMovies.count, 1, "Debe encontrarla ignorando mayúsculas y espacios")
        XCTAssertEqual(viewModel.filteredMovies.first?.title, "The Batman")
    }

    // Caso sin resultados: texto vacío o película que no existe
    func testSearchEmptyOrNoMatchCase() {
        let viewModel = FindViewModel()

        // Texto vacío
        viewModel.searchText = ""
        XCTAssertTrue(viewModel.filteredMovies.isEmpty, "Con texto vacío la lista debe estar vacía")

        // Película que no existe
        viewModel.searchText = "PeliculaInventada999"
        XCTAssertTrue(viewModel.filteredMovies.isEmpty, "Si no hay coincidencias la lista debe estar vacía")
    }
}

// Pruebas para autenticación y métodos HTTP
final class AuthAndNetworkTests: XCTestCase {

    func testRequestMethodEnum() {
        XCTAssertEqual(RequestMethod.get.rawValue, "GET")
        XCTAssertEqual(RequestMethod.post.rawValue, "POST")
        XCTAssertEqual(RequestMethod.put.rawValue, "PUT")
        XCTAssertEqual(RequestMethod.delete.rawValue, "DELETE")
        XCTAssertEqual(RequestMethod.patch.rawValue, "PATCH")
    }

    func testNetworkErrorDescriptions() {
        let invalidURL = NetworkError.invalidURL
        XCTAssertNotNil(invalidURL.errorDescription)

        let serverError = NetworkError.httpError(statusCode: 500)
        XCTAssertTrue(serverError.errorDescription?.contains("500") == true)
    }

    func testAuthServiceValidation() {
        let service = AuthService()
        XCTAssertFalse(service.validateCredentials(email: "", password: ""))
        XCTAssertFalse(service.validateCredentials(email: "leo@cuevana.com", password: ""))
        XCTAssertTrue(service.validateCredentials(email: "leo@cuevana.com", password: "1234"))
    }

    func testLoginViewModelValidation() {
        let viewModel = LoginViewModel()
        XCTAssertFalse(viewModel.isValid)

        viewModel.mail = "leo@cuevana.com"
        viewModel.password = "1234"
        XCTAssertTrue(viewModel.isValid)
    }
}

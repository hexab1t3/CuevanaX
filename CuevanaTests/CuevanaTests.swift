//
//  CuevanaTests.swift
//  CuevanaTests
//
//  Created by Leonardo Alarcón García.
//

import XCTest
@testable import Cuevana

// MARK: - Pruebas para Persistencia de Favoritos en SwiftData (1 test por acción)
@MainActor
final class FavoritesSwiftDataActionTests: XCTestCase {

    private func makeStore() -> FavoritesStore {
        FavoritesStore(container: FavoritesStore.inMemoryContainer())
    }

    // Acción: Agregar una película nueva a la colección de favoritos
    func testAddFavoriteMovieAction() {
        let store = makeStore()
        let movie = ExampleMovies[0]

        store.add(movie)

        XCTAssertTrue(store.isFavorite(movie), "La película debe quedar registrada como favorita")
        XCTAssertEqual(store.items.count, 1, "Debe existir exactamente 1 elemento en el almacén")
        XCTAssertEqual(store.items.first?.title, movie.title, "El título almacenado debe coincidir")
    }

    // Acción: Reinsertar una película existente no genera duplicados
    func testPreventDuplicateMovieAction() {
        let store = makeStore()
        let movie = ExampleMovies[1]

        store.add(movie)
        store.add(movie)

        XCTAssertEqual(store.items.count, 1, "No debe duplicarse la película ya persistida")
    }

    // Acción: Eliminar una película existente de favoritos
    func testRemoveFavoriteMovieAction() {
        let store = makeStore()
        let movie = ExampleMovies[1]

        store.add(movie)
        store.remove(movie)

        XCTAssertFalse(store.isFavorite(movie), "La película removida ya no debe constar como favorita")
        XCTAssertEqual(store.items.count, 0, "El almacén de favoritos debe quedar vacío")
    }

    // Acción: Alternar (toggle) una película inexistente la agrega a favoritos
    func testToggleFavoriteAddsMovieAction() {
        let store = makeStore()
        let movie = ExampleMovies[2]

        store.alternate(movie)

        XCTAssertTrue(store.isFavorite(movie), "Alternar una película no guardada debe agregarla")
    }

    // Acción: Alternar (toggle) una película ya existente la retira de favoritos
    func testToggleFavoriteRemovesMovieAction() {
        let store = makeStore()
        let movie = ExampleMovies[2]

        store.add(movie)
        store.alternate(movie)

        XCTAssertFalse(store.isFavorite(movie), "Alternar una película guardada debe retirarla")
    }

    // Acción: Consultar si una película es favorita en un almacén vacío retorna falso
    func testQueryFavoriteInEmptyStoreAction() {
        let store = makeStore()
        let movie = ExampleMovies[0]

        XCTAssertFalse(store.isFavorite(movie), "Una película no guardada debe retornar false")
        XCTAssertTrue(store.allFavoriteMovies().isEmpty, "La lista total debe estar vacía")
    }
}

// MARK: - Pruebas para Búsqueda de Películas contra el servicio (1 test por acción)
@MainActor
final class SearchMovieActionTests: XCTestCase {

    // Acción: Búsqueda con coincidencias muestra los resultados del servicio
    func testSearchWithMatchingQueryAction() async {
        let service = StubMovieService(searchResult: .success([ExampleMovies[3]]))
        let viewModel = FindViewModel(service: service)

        await viewModel.performSearch(for: "Batman")

        XCTAssertEqual(viewModel.state, .results([ExampleMovies[3]]))
        XCTAssertEqual(service.receivedQueries, ["Batman"])
    }

    // Acción: La búsqueda envía el texto sin espacios sobrantes
    func testSearchTrimsWhitespaceAction() async {
        let service = StubMovieService(searchResult: .success([ExampleMovies[3]]))
        let viewModel = FindViewModel(service: service)

        await viewModel.performSearch(for: "   Batman   ")

        XCTAssertEqual(service.receivedQueries, ["Batman"])
    }

    // Acción: Búsqueda con cadena vacía regresa a .idle sin llamar a la API
    func testSearchWithEmptyQueryReturnsIdleAction() async {
        let service = StubMovieService(searchResult: .success(ExampleMovies))
        let viewModel = FindViewModel(service: service)

        await viewModel.performSearch(for: "   ")

        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertTrue(service.receivedQueries.isEmpty, "No debe consultarse la API con texto vacío")
    }

    // Acción: Búsqueda sin coincidencias termina en .empty
    func testSearchWithNoMatchQueryReturnsEmptyStateAction() async {
        let service = StubMovieService(searchResult: .success([]))
        let viewModel = FindViewModel(service: service)

        await viewModel.performSearch(for: "PeliculaTotalmenteInexistente123")

        XCTAssertEqual(viewModel.state, .empty)
    }

    // Acción: Un error del servicio transiciona el estado a .error
    func testSearchFailureSetsErrorStateAction() async {
        let service = StubMovieService(searchResult: .failure(NetworkError.httpError(statusCode: 500)))
        let viewModel = FindViewModel(service: service)

        await viewModel.performSearch(for: "Batman")

        XCTAssertEqual(viewModel.state, .error(NetworkError.httpError(statusCode: 500).localizedDescription))
    }

    // Acción: Escribir en el buscador dispara la búsqueda remota tras la pausa
    func testTypingTriggersDebouncedRemoteSearchAction() async throws {
        let service = StubMovieService(searchResult: .success([ExampleMovies[0]]))
        let viewModel = FindViewModel(service: service, debounceNanoseconds: 0)

        viewModel.searchText = "Dune"
        for _ in 0..<50 where viewModel.state != .results([ExampleMovies[0]]) {
            try await Task.sleep(nanoseconds: 20_000_000)
        }

        XCTAssertEqual(viewModel.state, .results([ExampleMovies[0]]))
    }
}

// MARK: - Pruebas para el Servicio de Autenticación (1 test por cada acción)
final class AuthServiceActionTests: XCTestCase {

    // Acción: Iniciar sesión exitoso con credenciales correctas
    func testLoginActionWithValidCredentialsSucceeds() {
        let service = AuthService()
        let result = service.login(email: "leo@cuevana.com", password: "1234")
        XCTAssertTrue(result, "El servicio de autenticación debe permitir el acceso para credenciales válidas")
    }

    // Acción: Iniciar sesión fallido cuando las credenciales están vacías
    func testLoginActionWithEmptyCredentialsFails() {
        let service = AuthService()
        let result = service.login(email: "", password: "")
        XCTAssertFalse(result, "El servicio debe denegar el acceso ante credenciales vacías")
    }

    // Acción: Iniciar sesión fallido cuando no se proporciona contraseña
    func testLoginActionWithMissingPasswordFails() {
        let service = AuthService()
        let result = service.login(email: "leo@cuevana.com", password: "")
        XCTAssertFalse(result, "El servicio debe denegar el acceso si la contraseña está ausente")
    }

    // Acción: Iniciar sesión fallido cuando no se proporciona correo
    func testLoginActionWithMissingEmailFails() {
        let service = AuthService()
        let result = service.login(email: "", password: "1234")
        XCTAssertFalse(result, "El servicio debe denegar el acceso si el correo está ausente")
    }

    // Acción: Validación rechaza campos totalmente vacíos
    func testValidateCredentialsRejectsEmptyEmailAndEmptyPasswordAction() {
        let service = AuthService()
        let isValid = service.validateCredentials(email: "", password: "")
        XCTAssertFalse(isValid, "La validación debe ser falsa si ambos campos están vacíos")
    }

    // Acción: Validación rechaza entradas consistentes solo en espacios en blanco
    func testValidateCredentialsRejectsWhitespaceOnlyAction() {
        let service = AuthService()
        let isValid = service.validateCredentials(email: "   ", password: "   ")
        XCTAssertFalse(isValid, "La validación debe rechazar entradas con solo espacios")
    }

    // Acción: Validación rechaza credenciales con contraseña faltante
    func testValidateCredentialsRejectsMissingPasswordAction() {
        let service = AuthService()
        let isValid = service.validateCredentials(email: "leo@cuevana.com", password: "")
        XCTAssertFalse(isValid, "La validación debe ser falsa si falta la contraseña")
    }

    // Acción: Validación rechaza credenciales con correo faltante
    func testValidateCredentialsRejectsMissingEmailAction() {
        let service = AuthService()
        let isValid = service.validateCredentials(email: "", password: "1234")
        XCTAssertFalse(isValid, "La validación debe ser falsa si falta el correo")
    }

    // Acción: Validación aprueba credenciales con datos completos
    func testValidateCredentialsAcceptsValidCredentialsAction() {
        let service = AuthService()
        let isValid = service.validateCredentials(email: "leo@cuevana.com", password: "1234")
        XCTAssertTrue(isValid, "La validación debe ser verdadera cuando ambos datos están presentes")
    }
}

// MARK: - Pruebas para LoginViewModel (1 test por cada acción)
final class LoginViewModelActionTests: XCTestCase {

    // Acción: El ViewModel recién creado inicia en estado no válido
    func testInitialViewModelValidationIsFalseAction() {
        let viewModel = LoginViewModel()
        XCTAssertFalse(viewModel.isValid, "El estado inicial de validación debe ser falso")
    }

    // Acción: Rellenar credenciales válidas actualiza la validez a true
    func testFillingValidCredentialsUpdatesValidationToTrueAction() {
        let viewModel = LoginViewModel()
        viewModel.mail = "leo@cuevana.com"
        viewModel.password = "1234"
        XCTAssertTrue(viewModel.isValid, "El estado debe ser válido tras proveer correo y contraseña")
    }

    // Acción: Iniciar sesión exitoso activa autenticación y limpia mensaje de error
    func testLoginSuccessActionUpdatesAuthenticationState() {
        let viewModel = LoginViewModel()
        viewModel.mail = "leo@cuevana.com"
        viewModel.password = "1234"
        var isAuthenticated = false

        viewModel.login(isAuthenticated: &isAuthenticated)

        XCTAssertTrue(isAuthenticated, "isAuthenticated debe cambiar a true tras login exitoso")
        XCTAssertNil(viewModel.errorMessage, "errorMessage debe ser nil tras login exitoso")
    }

    // Acción: Iniciar sesión con campos vacíos deniega acceso y genera mensaje descriptivo
    func testLoginFailureActionLeavesUnauthenticatedAndSetsErrorMessage() {
        let viewModel = LoginViewModel()
        viewModel.mail = ""
        viewModel.password = ""
        var isAuthenticated = false

        viewModel.login(isAuthenticated: &isAuthenticated)

        XCTAssertFalse(isAuthenticated, "isAuthenticated debe mantenerse en false tras intento fallido")
        XCTAssertNotNil(viewModel.errorMessage, "Debe configurarse un mensaje de error explicativo")
    }
}

// MARK: - Pruebas para FavoritesViewModel y su Enum de Estado (1 test por acción)
@MainActor
final class FavoritesViewModelActionTests: XCTestCase {

    // Servicio simulado para aislar las pruebas de red
    final class MockMovieService: MovieServiceProtocol {
        var shouldFail: Bool = false
        var mockMovies: [Movie] = ExampleMovies

        func fetchPopularMovies(page: Int) async throws -> [Movie] {
            if shouldFail {
                throw NetworkError.httpError(statusCode: 500)
            }
            return mockMovies
        }

        func searchMovies(query: String) async throws -> [Movie] {
            if shouldFail {
                throw NetworkError.httpError(statusCode: 500)
            }
            return mockMovies.filter { $0.title.contains(query) }
        }
    }

    // Acción: Carga exitosa de películas transiciona el estado reactivo a .loaded
    func testLoadMoviesSuccessActionSetsLoadedState() async {
        let mockService = MockMovieService()
        mockService.shouldFail = false
        let viewModel = FavoritesViewModel(service: mockService)

        await viewModel.loadMovies()

        XCTAssertEqual(viewModel.state, .loaded(ExampleMovies), "El estado debe ser .loaded con las películas entregadas por el servicio")
        XCTAssertFalse(viewModel.isLoading, "isLoading debe ser false")
        XCTAssertNil(viewModel.errorMessage, "errorMessage debe ser nil")
    }

    // Acción: Fallo de red en la carga transiciona el estado reactivo a .error
    func testLoadMoviesFailureActionSetsErrorState() async {
        let mockService = MockMovieService()
        mockService.shouldFail = true
        let viewModel = FavoritesViewModel(service: mockService)

        await viewModel.loadMovies()

        if case .error(let message) = viewModel.state {
            XCTAssertFalse(message.isEmpty, "El mensaje de error no debe ser vacío")
        } else {
            XCTFail("El estado debió haber sido .error al fallar el servicio")
        }
        XCTAssertFalse(viewModel.isLoading, "isLoading debe ser false")
    }

    // Acción: Alternar favorito desde el ViewModel actualiza el almacén de persistencia
    func testToggleFavoriteActionFromViewModel() {
        let store = FavoritesStore(container: FavoritesStore.inMemoryContainer())
        let viewModel = FavoritesViewModel(service: MockMovieService(), favoritesStore: store)
        let movie = ExampleMovies[0]

        XCTAssertFalse(viewModel.isFavorite(movie: movie, store: store))

        viewModel.toggleFavorite(movie: movie, store: store)
        XCTAssertTrue(viewModel.isFavorite(movie: movie, store: store))

        viewModel.toggleFavorite(movie: movie, store: store)
        XCTAssertFalse(viewModel.isFavorite(movie: movie, store: store))
    }

    // Acción: Remover favorito desde el ViewModel retira la película
    func testRemoveFavoriteActionFromViewModel() {
        let store = FavoritesStore(container: FavoritesStore.inMemoryContainer())
        let viewModel = FavoritesViewModel(service: MockMovieService(), favoritesStore: store)
        let movie = ExampleMovies[0]

        viewModel.toggleFavorite(movie: movie, store: store)
        XCTAssertTrue(viewModel.isFavorite(movie: movie, store: store))

        viewModel.removeFavorite(movie: movie, store: store)
        XCTAssertFalse(viewModel.isFavorite(movie: movie, store: store))
    }
}

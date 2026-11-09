//
//  NetworkingTests.swift
//  CuevanaTests
//

import XCTest
@testable import Cuevana

// Servicio simulado para aislar las pruebas de red (los resultados se consumen en orden)
@MainActor
final class StubMovieService: MovieServiceProtocol {
    var popularResults: [Result<[Movie], Error>]
    var searchResult: Result<[Movie], Error>
    private(set) var requestedPages: [Int] = []
    private(set) var receivedQueries: [String] = []

    init(
        popularResults: [Result<[Movie], Error>] = [.success(ExampleMovies)],
        searchResult: Result<[Movie], Error> = .success([])
    ) {
        self.popularResults = popularResults
        self.searchResult = searchResult
    }

    func fetchPopularMovies(page: Int) async throws -> [Movie] {
        requestedPages.append(page)
        let result = popularResults.count > 1 ? popularResults.removeFirst() : popularResults[0]
        return try result.get()
    }

    func searchMovies(query: String) async throws -> [Movie] {
        receivedQueries.append(query)
        return try searchResult.get()
    }
}

// Simula las respuestas HTTP sin salir a internet
final class StubURLProtocol: URLProtocol {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    nonisolated(unsafe) static var lastRequest: URLRequest?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.lastRequest = request
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Pruebas para MovieServices con respuestas HTTP simuladas (1 test por acción)

@MainActor
final class MovieServicesTests: XCTestCase {

    private let popularJSON = """
    {
      "page": 1,
      "results": [
        {
          "id": 693134,
          "title": "Dune: Parte Dos",
          "overview": "Paul Atreides se une a los Fremen.",
          "vote_average": 8.2,
          "release_date": "2024-02-27",
          "poster_path": "/dune.jpg"
        }
      ]
    }
    """

    override func tearDown() {
        StubURLProtocol.handler = nil
        StubURLProtocol.lastRequest = nil
        super.tearDown()
    }

    private func makeService(token: String? = "token-de-prueba") -> MovieServices {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return MovieServices(session: URLSession(configuration: configuration), tokenProvider: { token })
    }

    private func respond(status: Int, body: String) {
        StubURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
            return (response, Data(body.utf8))
        }
    }

    // Acción: Una respuesta exitosa se decodifica al modelo Movie
    func testFetchPopularMoviesSuccessDecodesMovies() async throws {
        respond(status: 200, body: popularJSON)

        let movies = try await makeService().fetchPopularMovies(page: 1)

        XCTAssertEqual(movies.count, 1)
        XCTAssertEqual(movies.first?.title, "Dune: Parte Dos")
        XCTAssertEqual(movies.first?.year, 2024)
        XCTAssertEqual(movies.first?.tmdbId, 693134)
        XCTAssertEqual(movies.first?.posterURL?.absoluteString, "https://image.tmdb.org/t/p/w500/dune.jpg")
    }

    // Acción: La petición usa el endpoint principal, GET y el header Bearer
    func testFetchPopularMoviesBuildsExpectedRequest() async throws {
        respond(status: 200, body: popularJSON)

        _ = try await makeService().fetchPopularMovies(page: 2)

        let request = try XCTUnwrap(StubURLProtocol.lastRequest)
        let components = try XCTUnwrap(request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) })
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(components.host, "api.themoviedb.org")
        XCTAssertEqual(components.path, "/3/movie/popular")
        XCTAssertTrue(components.queryItems?.contains(URLQueryItem(name: "page", value: "2")) ?? false)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token-de-prueba")
    }

    // Acción: Una respuesta sin resultados regresa una lista vacía
    func testFetchPopularMoviesEmptyResultsReturnsEmptyArray() async throws {
        respond(status: 200, body: #"{"page": 1, "results": []}"#)

        let movies = try await makeService().fetchPopularMovies(page: 1)

        XCTAssertTrue(movies.isEmpty)
    }

    // Acción: Un código HTTP no exitoso lanza httpError
    func testFetchPopularMoviesHTTPErrorThrowsStatusCode() async {
        respond(status: 401, body: #"{"status_message": "Invalid API key"}"#)

        do {
            _ = try await makeService().fetchPopularMovies(page: 1)
            XCTFail("Debió lanzar un error HTTP")
        } catch {
            XCTAssertEqual(error as? NetworkError, .httpError(statusCode: 401))
        }
    }

    // Acción: Un JSON inválido lanza decodingError
    func testFetchPopularMoviesInvalidJSONThrowsDecodingError() async {
        respond(status: 200, body: #"{"resultados": "esto no es lo esperado"}"#)

        do {
            _ = try await makeService().fetchPopularMovies(page: 1)
            XCTFail("Debió lanzar un error de decodificación")
        } catch {
            guard case .decodingError = error as? NetworkError else {
                return XCTFail("Se esperaba .decodingError y llegó \(error)")
            }
        }
    }

    // Acción: Sin conexión a internet lanza connectivity
    func testFetchPopularMoviesOfflineThrowsConnectivityError() async {
        StubURLProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }

        do {
            _ = try await makeService().fetchPopularMovies(page: 1)
            XCTFail("Debió lanzar un error de conectividad")
        } catch {
            guard case .connectivity = error as? NetworkError else {
                return XCTFail("Se esperaba .connectivity y llegó \(error)")
            }
        }
    }

    // Acción: Sin token configurado no se hace la petición
    func testFetchPopularMoviesWithoutTokenThrowsMissingToken() async {
        respond(status: 200, body: popularJSON)

        do {
            _ = try await makeService(token: nil).fetchPopularMovies(page: 1)
            XCTFail("Debió lanzar missingToken")
        } catch {
            XCTAssertEqual(error as? NetworkError, .missingToken)
            XCTAssertNil(StubURLProtocol.lastRequest, "No debe salir ninguna petición sin token")
        }
    }
}

// MARK: - Pruebas para MoviesViewModel y sus estados de interfaz (1 test por acción)

@MainActor
final class MoviesViewModelStateTests: XCTestCase {

    // Acción: El ViewModel recién creado inicia en .idle
    func testInitialStateIsIdle() {
        let viewModel = MoviesViewModel(service: StubMovieService())

        XCTAssertEqual(viewModel.state, .idle)
    }

    // Acción: Carga exitosa de películas transiciona el estado a .content
    func testLoadMoviesSuccessSetsContentState() async {
        let viewModel = MoviesViewModel(service: StubMovieService(popularResults: [.success(ExampleMovies)]))

        await viewModel.loadMovies()

        XCTAssertEqual(viewModel.state, .content(ExampleMovies))
        XCTAssertEqual(viewModel.movies.count, ExampleMovies.count)
    }

    // Acción: Fallo del servicio transiciona el estado a .error
    func testLoadMoviesFailureSetsErrorState() async {
        let viewModel = MoviesViewModel(
            service: StubMovieService(popularResults: [.failure(NetworkError.httpError(statusCode: 500))])
        )

        await viewModel.loadMovies()

        XCTAssertEqual(viewModel.state, .error(NetworkError.httpError(statusCode: 500).localizedDescription))
        XCTAssertTrue(viewModel.movies.isEmpty)
    }

    // Acción: Respuesta sin resultados transiciona el estado a .empty
    func testLoadMoviesWithNoResultsSetsEmptyState() async {
        let viewModel = MoviesViewModel(service: StubMovieService(popularResults: [.success([])]))

        await viewModel.loadMovies()

        XCTAssertEqual(viewModel.state, .empty)
    }

    // Acción: Reintentar después de un error muestra el contenido
    func testRetryAfterErrorLoadsContent() async {
        let service = StubMovieService(popularResults: [
            .failure(NetworkError.connectivity("offline")),
            .success(ExampleMovies)
        ])
        let viewModel = MoviesViewModel(service: service)

        await viewModel.loadMovies()
        guard case .error = viewModel.state else { return XCTFail("Primero debió quedar en .error") }

        await viewModel.retry()

        XCTAssertEqual(viewModel.state, .content(ExampleMovies))
        XCTAssertEqual(service.requestedPages, [1, 1])
    }

    // Acción: loadIfNeeded no repite la consulta si ya hay datos
    func testLoadIfNeededDoesNotReloadWhenContentExists() async {
        let service = StubMovieService(popularResults: [.success(ExampleMovies)])
        let viewModel = MoviesViewModel(service: service)

        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()

        XCTAssertEqual(service.requestedPages, [1])
    }

    // Acción: Cargar más agrega la siguiente página sin duplicados
    func testLoadMoreAppendsNextPageWithoutDuplicates() async {
        let service = StubMovieService(popularResults: [
            .success(Array(ExampleMovies.prefix(3))),
            .success(Array(ExampleMovies.suffix(3)))
        ])
        let viewModel = MoviesViewModel(service: service)

        await viewModel.loadMovies()
        await viewModel.loadMoreMovies()

        XCTAssertEqual(viewModel.state, .content(ExampleMovies))
        XCTAssertEqual(service.requestedPages, [1, 2])
    }

    // Acción: Un error al cargar más conserva el contenido y expone el error
    func testLoadMoreFailureKeepsContentAndExposesError() async {
        let service = StubMovieService(popularResults: [
            .success(ExampleMovies),
            .failure(NetworkError.httpError(statusCode: 503))
        ])
        let viewModel = MoviesViewModel(service: service)

        await viewModel.loadMovies()
        await viewModel.loadMoreMovies()

        XCTAssertEqual(viewModel.state, .content(ExampleMovies))
        XCTAssertNotNil(viewModel.loadMoreErrorMessage)
        XCTAssertFalse(viewModel.isLoadingMore)
    }
}

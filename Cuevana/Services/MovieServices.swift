//
//  MovieServices.swift
//  Cuevana
//
//  Created by Leonardo Alarcón García on 01/11/26.
//

import Foundation

/// Protocolo que define los métodos disponibles para obtener información de películas desde una API.
protocol MovieServiceProtocol {
    func fetchPopularMovies(page: Int) async throws -> [Movie]
    func searchMovies(query: String) async throws -> [Movie]
}

extension MovieServiceProtocol {
    func fetchPopularMovies() async throws -> [Movie] {
        try await fetchPopularMovies(page: 1)
    }
}

/// Servicio encargado del consumo de la API de TheMovieDB (TMDB).
/// Las credenciales son provistas de manera desacoplada a través de TMDBConfig,
/// evitando almacenar llaves directas dentro del repositorio.
class MovieServices: MovieServiceProtocol {
    private let host: String
    private let session: URLSession
    private let tokenProvider: () -> String?
    private let decoder = JSONDecoder()

    init(
        host: String = TMDBConfig.host,
        session: URLSession = .shared,
        tokenProvider: @escaping () -> String? = { TMDBConfig.bearerToken }
    ) {
        self.host = host
        self.session = session
        self.tokenProvider = tokenProvider
    }

    /// Obtiene las películas populares de TMDB paginadas
    func fetchPopularMovies(page: Int = 1) async throws -> [Movie] {
        let response: TMDBMovieResponse = try await request(
            path: "/3/movie/popular",
            queryItems: [URLQueryItem(name: "page", value: String(page))]
        )
        return response.results.map { $0.toMovie() }
    }

    /// Busca películas por título en TMDB
    func searchMovies(query: String) async throws -> [Movie] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }

        let response: TMDBMovieResponse = try await request(
            path: "/3/search/movie",
            queryItems: [URLQueryItem(name: "query", value: trimmedQuery)]
        )
        return response.results.map { $0.toMovie() }
    }

    /// Ejecuta la petición, valida el código HTTP y decodifica la respuesta
    private func request<T: Decodable>(path: String, queryItems: [URLQueryItem]) async throws -> T {
        guard let token = tokenProvider(), !token.isEmpty else {
            throw NetworkError.missingToken
        }

        var components = URLComponents()
        components.scheme = TMDBConfig.scheme
        components.host = host
        components.path = path
        components.queryItems = [URLQueryItem(name: "language", value: TMDBConfig.defaultLanguage)] + queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = RequestMethod.get.rawValue
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw CancellationError()
        } catch let urlError as URLError {
            throw NetworkError.connectivity(urlError.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
}

// MARK: - DTOs de TMDB (Data Transfer Objects)
struct TMDBMovieResponse: Decodable {
    let results: [TMDBMovieItem]
}

struct TMDBMovieItem: Decodable {
    let id: Int
    let title: String
    let overview: String
    let voteAverage: Double
    let releaseDate: String?
    let posterPath: String?
    let backdropPath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
    }

    /// Transforma el DTO de red al modelo de dominio Movie
    func toMovie() -> Movie {
        let extractedYear = Int(releaseDate?.prefix(4) ?? "") ?? 2024
        let stableUUID = UUID(uuidString: String(format: "%08d-0000-0000-0000-000000000000", id)) ?? UUID()

        return Movie(
            id: stableUUID,
            title: title,
            year: extractedYear,
            duration: 120,
            gender: "Película",
            qualification: voteAverage,
            premiereDate: releaseDate ?? "",
            sinopsis: overview.isEmpty ? "Sin sinopsis disponible." : overview,
            tmdbId: id,
            posterPath: posterPath,
            backdropPath: backdropPath
        )
    }
}

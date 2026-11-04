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
class MovieServices: MovieServiceProtocol {
    private let apiKey = "04ea24015d782d98c7a91d1ea1d0fa1c"
    private let host = "api.themoviedb.org"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Obtiene las películas populares de TMDB paginadas
    func fetchPopularMovies(page: Int = 1) async throws -> [Movie] {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/3/movie/popular"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: "es-MX"),
            URLQueryItem(name: "page", value: String(page))
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoded = try JSONDecoder().decode(TMDBMovieResponse.self, from: data)
            return decoded.results.map { $0.toMovie() }
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }

    /// Busca películas por título en TMDB
    func searchMovies(query: String) async throws -> [Movie] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }

        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/3/search/movie"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: "es-MX"),
            URLQueryItem(name: "query", value: trimmedQuery)
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoded = try JSONDecoder().decode(TMDBMovieResponse.self, from: data)
            return decoded.results.map { $0.toMovie() }
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

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case posterPath = "poster_path"
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
            posterPath: posterPath
        )
    }
}

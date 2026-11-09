//
//  MoviesViewModel.swift
//  Cuevana
//

import Foundation
import Observation

@Observable
class MoviesViewModel {

    enum ViewState: Equatable {
        case idle
        case loading
        case content([Movie])
        case empty
        case error(String)
    }

    // Única fuente de verdad para el estado de la consulta
    private(set) var state: ViewState = .idle
    private(set) var isLoadingMore: Bool = false
    private(set) var loadMoreErrorMessage: String? = nil

    var movies: [Movie] {
        if case .content(let list) = state { return list }
        return []
    }

    private var currentPage = 1
    private let service: MovieServiceProtocol

    init(service: MovieServiceProtocol = MovieServices()) {
        self.service = service
    }

    @MainActor
    func loadIfNeeded() async {
        guard state == .idle else { return }
        await loadMovies()
    }

    @MainActor
    func loadMovies() async {
        guard state != .loading else { return }
        state = .loading
        loadMoreErrorMessage = nil
        currentPage = 1

        do {
            let fetched = try await service.fetchPopularMovies(page: currentPage)
            state = fetched.isEmpty ? .empty : .content(fetched)
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    @MainActor
    func retry() async {
        await loadMovies()
    }

    // Función para cargar la siguiente página
    @MainActor
    func loadMoreMovies() async {
        guard case .content(let current) = state, !isLoadingMore else { return }

        isLoadingMore = true
        loadMoreErrorMessage = nil
        let nextPage = currentPage + 1

        do {
            let more = try await service.fetchPopularMovies(page: nextPage)
            currentPage = nextPage
            // TMDB puede repetir películas entre páginas
            let knownIDs = Set(current.map(\.id))
            state = .content(current + more.filter { !knownIDs.contains($0.id) })
        } catch is CancellationError {
        } catch {
            loadMoreErrorMessage = error.localizedDescription
        }

        isLoadingMore = false
    }
}

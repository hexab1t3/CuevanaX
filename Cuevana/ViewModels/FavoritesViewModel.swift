//
//  FavoritesViewModel.swift
//  Cuevana
//
//  Created by Leonardo Alarcón García on 26/10/26.
//

import Foundation
import Observation

@Observable
class FavoritesViewModel {
    
    // Enum con los diferentes estados de la vista según las recomendaciones del profesor
    enum State: Equatable {
        case idle
        case loading
        case loaded([Movie])
        case error(String)
    }
    
    // Variable de estado que unifica el ciclo de vida de la vista
    var state: State = .idle
    
    // Propiedades computadas de conveniencia
    var movies: [Movie] {
        if case .loaded(let list) = state { return list }
        return []
    }
    
    var isLoading: Bool {
        state == .loading
    }
    
    var errorMessage: String? {
        if case .error(let message) = state { return message }
        return nil
    }
    
    private let service: MovieServiceProtocol
    private var favoritesStore: FavoritesStore?
    
    init(service: MovieServiceProtocol = MovieServices(), favoritesStore: FavoritesStore? = nil) {
        self.service = service
        self.favoritesStore = favoritesStore
        Task {
            await loadMovies()
        }
    }
    
    @MainActor
    func loadMovies() async {
        state = .loading
        do {
            let fetchedMovies = try await service.fetchPopularMovies(page: 1)
            state = .loaded(fetchedMovies)
        } catch {
            print("Error al cargar películas para favoritos: \(error.localizedDescription)")
            state = .error(error.localizedDescription)
        }
    }
    
    // Consulta si una película está marcada como favorita
    func isFavorite(movie: Movie, store: FavoritesStore? = nil) -> Bool {
        let activeStore = store ?? favoritesStore
        return activeStore?.isFavorite(movie) ?? false
    }
    
    // Agrega o quita la película de favoritos
    @MainActor
    func toggleFavorite(movie: Movie, store: FavoritesStore? = nil) {
        let activeStore = store ?? favoritesStore
        activeStore?.alternate(movie)
    }

    // Quita la película de la colección
    @MainActor
    func removeFavorite(movie: Movie, store: FavoritesStore? = nil) {
        let activeStore = store ?? favoritesStore
        activeStore?.remove(movie)
    }
    
    // Retorna las películas favoritas desde SwiftData o filtrando la lista provista
    func getFavoriteMovies(from list: [Movie]? = nil, store: FavoritesStore? = nil) -> [Movie] {
        let activeStore = store ?? favoritesStore
        guard let activeStore = activeStore else { return [] }
         
        if let list = list, !list.isEmpty {
            return activeStore.favoriteMovies(from: list)
        } else {
            return activeStore.allFavoriteMovies()
        }
    }
}

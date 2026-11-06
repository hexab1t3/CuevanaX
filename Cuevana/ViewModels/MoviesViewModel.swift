//
//  MoviesViewModel.swift
//  Cuevana
//

import Foundation
import Observation

@Observable
class MoviesViewModel {
    var movies: [Movie] = []
    var isLoading: Bool = false
    var isLoadingMore: Bool = false
    var errorMessage: String? = nil
    
    private var currentPage = 1
    private let service: MovieServiceProtocol
    
    init(service: MovieServiceProtocol = MovieServices()) {
        self.service = service
        Task {
            await loadMovies()
        }
    }
    
    @MainActor
    func loadMovies() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        currentPage = 1
        
        do {
            self.movies = try await service.fetchPopularMovies(page: currentPage)
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error al cargar películas: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // Función para cargar la siguiente página (paginación infinita)
    @MainActor
    func loadMoreMoviesIfNeeded(currentMovie movie: Movie) async {
        guard let lastMovie = movies.last, lastMovie.id == movie.id, !isLoadingMore else {
            return
        }
        
        isLoadingMore = true
        currentPage += 1
        
        do {
            let moreMovies = try await service.fetchPopularMovies(page: currentPage)
            self.movies.append(contentsOf: moreMovies)
        } catch {
            print("Error al cargar más películas: \(error.localizedDescription)")
            currentPage -= 1 // Revertir el incremento si falla
        }
        
        isLoadingMore = false
    }
}

//
//  FindViewModel.swift
//  Cuevana
//

import Foundation
import Observation

@Observable
class FindViewModel {
    var searchText = "" {
        didSet {
            updateFilteredMoviesSync()
            searchTask?.cancel()
            searchTask = Task {
                await performSearch(for: searchText)
            }
        }
    }
    
    var filteredMovies: [Movie] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let service: MovieServiceProtocol
    private var searchTask: Task<Void, Never>? = nil
    
    init(service: MovieServiceProtocol = MovieServices()) {
        self.service = service
    }
    
    /// Búsqueda síncrona inmediata sobre el catálogo local (útil para pruebas unitarias y retroalimentación instantánea)
    private func updateFilteredMoviesSync() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            filteredMovies = []
            return
        }
        let matches = ExampleMovies.filter { $0.title.localizedCaseInsensitiveContains(query) }
        filteredMovies = matches
    }
    
    @MainActor
    func performSearch(for query: String) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedQuery.isEmpty {
            self.filteredMovies = []
            self.isLoading = false
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Breve pausa para evitar saturar la API mientras el usuario teclea
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        guard !Task.isCancelled else { return }
        
        do {
            let results = try await service.searchMovies(query: trimmedQuery)
            if !Task.isCancelled {
                // Si la API devuelve resultados, los usamos; si no, conservamos los resultados locales si coincidieron
                if !results.isEmpty || filteredMovies.isEmpty {
                    self.filteredMovies = results
                }
            }
        } catch {
            print("Error al buscar películas: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

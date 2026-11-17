//
//  FavoritesStore.swift
//  Cuevana
//

import Foundation
import SwiftData
import Observation

// Servicio de persistencia para la colección de favoritos con SwiftData
@Observable
class FavoritesStore {
    var items: [FavoriteMovie] = []
    private let modelContainer: ModelContainer

    @MainActor
    private var context: ModelContext {
        modelContainer.mainContext
    }

    // Contenedor por defecto guardado en disco
    static var defaultContainer: ModelContainer = {
        let schema = Schema([FavoriteMovie.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Error al inicializar SwiftData: \(error)")
        }
    }()

    // Contenedor en memoria para pruebas unitarias
    static func inMemoryContainer() -> ModelContainer {
        let schema = Schema([FavoriteMovie.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [config])
    }


    init(container: ModelContainer = FavoritesStore.defaultContainer) {
        self.modelContainer = container
        fetchItems()
    }

    // Set de IDs para consultas rápidas
    var ids: Set<String> {
        Set(items.map { $0.id })
    }

    // Consulta los elementos persistidos
    @MainActor
    func fetchItems() {
        let descriptor = FetchDescriptor<FavoriteMovie>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        )
        do {
            items = try context.fetch(descriptor)
        } catch {
            print("Error al obtener favoritos: \(error)")
            items = []
        }
    }

    // Obtiene el identificador estable de la película
    func movieIdentifier(_ movie: Movie) -> String {
        movie.tmdbId != nil ? String(movie.tmdbId!) : movie.id.uuidString
    }

    // Revisa si la película ya está guardada
    func isFavorite(_ movie: Movie) -> Bool {
        let id = movieIdentifier(movie)
        return items.contains(where: { $0.id == id })
    }

    // Guarda una película evitando duplicados
    @MainActor
    func add(_ movie: Movie) {
        let id = movieIdentifier(movie)
        guard !items.contains(where: { $0.id == id }) else { return }

        let item = FavoriteMovie(from: movie)
        context.insert(item)
        try? context.save()
        fetchItems()
    }

    // Elimina una película de favoritos
    @MainActor
    func remove(_ movie: Movie) {
        let id = movieIdentifier(movie)
        if let existing = items.first(where: { $0.id == id }) {
            context.delete(existing)
            try? context.save()
            fetchItems()
        }
    }

    // Alterna el estado (si está la quita, si no está la agrega)
    @MainActor
    func alternate(_ movie: Movie) {
        if isFavorite(movie) {
            remove(movie)
        } else {
            add(movie)
        }
    }

    // Regresa todas las películas guardadas convertidas a Movie
    func allFavoriteMovies() -> [Movie] {
        items.map { $0.toMovie() }
    }

    // Filtra una lista recibida con las que sean favoritas
    func favoriteMovies(from allMovies: [Movie]) -> [Movie] {
        allMovies.filter { isFavorite($0) }
    }
}

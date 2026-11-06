//
//  MovieDetailViewModel.swift
//  Cuevana
//
//  Created by Leonardo Alarcón García on 18/10/26.
//

import Foundation
import Observation

@Observable
class MovieDetailViewModel {
    let movie: Movie

    init(movie: Movie) {
        self.movie = movie
    }

    /// Calificación con formato a un decimal
    var formattedRating: String {
        String(format: "%.1f", movie.qualification)
    }

    /// Texto con los metadatos resumidos para la vista
    var formattedMetadata: String {
        "\(movie.year) • \(movie.gender) • ★ \(formattedRating)"
    }

    /// Verifica si la película actual está marcada como favorita en el Store
    func isFavorite(favoritesStore: FavoritesStore) -> Bool {
        favoritesStore.isFavorite(movie)
    }

    // Agrega o quita la película de favoritos
    @MainActor
    func toggleFavorite(favoritesStore: FavoritesStore) {
        favoritesStore.alternate(movie)
    }

    /// Título para el botón de favoritos según su estado
    func buttonTitle(isFavorite: Bool) -> String {
        isFavorite ? "Quitar de Favoritos" : "Agregar a Favoritos"
    }
}

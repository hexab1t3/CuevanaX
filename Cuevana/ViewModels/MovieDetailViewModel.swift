//
//  MovieDetailViewModel.swift
//  Cuevana
//
//  Created by Leonardo Alarcón García on 18/10/26.
//

import Foundation

@Observable
class MovieDetailViewModel {
    let movie: Movie

    init(movie: Movie) {
        self.movie = movie
    }

    func toggleFavorite(favoritesStore: FavoritesStore) {
        favoritesStore.alternate(movie)
    }
}


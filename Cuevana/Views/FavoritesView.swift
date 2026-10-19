//
//  FavoritosView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(FavoritesStore.self) var favoritesStore

    var body: some View {
        NavigationStack {
            VStack {
                Text("Tus Favoritos")
                    .font(.title2)
                    .bold()
                    .padding()

                let favoriteList = favoritesStore.favoriteMovies(from: ExampleMovies)

                if favoriteList.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Text("💔")
                            .font(.system(size: 80))
                        Text("No tienes películas favoritas")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    List(favoriteList) { movie in
                        NavigationLink(value: movie) {
                            Text(movie.title)
                        }
                    }
                }
            }
            .navigationTitle("Favoritos")
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie)
            }
        }
    }
}
#Preview {
    FavoritesView()
        .environment(FavoritesStore())
} 


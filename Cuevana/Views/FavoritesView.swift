//
//  FavoritesView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI

struct FavoritesView: View {
    // Store con SwiftData inyectado desde el entorno
    @Environment(FavoritesStore.self) var favoritesStore
    @State private var viewModel = FavoritesViewModel()

    // Colores del tema
    private let deepNavyBackground = Color(red: 0.04, green: 0.06, blue: 0.12)
    private let cardBackground = Color(red: 0.08, green: 0.12, blue: 0.20)
    private let amberAccent = Color(red: 1.0, green: 0.75, blue: 0.0)

    var body: some View {
        // Lista de favoritos guardada localmente
        let favoriteList = viewModel.getFavoriteMovies(store: favoritesStore)

        NavigationStack {
            ZStack {
                deepNavyBackground
                    .ignoresSafeArea()

                VStack {
                    Text("Tus Favoritos")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding()

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
                        List {
                            ForEach(favoriteList) { movie in
                                NavigationLink(value: movie) {
                                    HStack(spacing: 12) {
                                        AsyncImage(url: movie.posterURL) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            Color.gray.opacity(0.3)
                                        }
                                        .frame(width: 50, height: 75)
                                        .cornerRadius(6)
                                        .clipped()

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(movie.title)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            
                                            HStack(spacing: 4) {
                                                Image(systemName: "star.fill")
                                                    .font(.caption)
                                                    .foregroundColor(amberAccent)
                                                
                                                Text(String(format: "%.1f", movie.qualification))
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                                .listRowBackground(cardBackground)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    let movie = favoriteList[index]
                                    viewModel.removeFavorite(movie: movie, store: favoritesStore)
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Favoritos")
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    FavoritesView()
        .environment(FavoritesStore(container: FavoritesStore.inMemoryContainer()))
}

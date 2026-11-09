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
    @Namespace private var zoomNamespace

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        // Lista de favoritos guardada localmente
        let favoriteList = viewModel.getFavoriteMovies(store: favoritesStore)

        NavigationStack {
            ZStack {
                AmbientBackground()

                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Tus Favoritos")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)

                        Spacer()

                        Text("\(favoriteList.count)")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .contentTransition(.numericText(value: Double(favoriteList.count)))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .glassEffect(.regular.tint(Theme.coral.opacity(0.4)), in: .capsule)
                    }
                    .padding(.horizontal)

                    if viewModel.state == .loading && favoriteList.isEmpty {
                        ProgressView("Cargando...")
                            .tint(Theme.amber)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if case .error(let errorMsg) = viewModel.state, favoriteList.isEmpty {
                        StatusMessageView(
                            icon: "exclamationmark.triangle",
                            title: "Algo salió mal",
                            message: errorMsg
                        )
                    } else if favoriteList.isEmpty {
                        StatusMessageView(
                            icon: "heart.slash",
                            title: "No tienes películas favoritas",
                            message: "Toca el corazón en cualquier película para guardarla aquí."
                        )
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(favoriteList, id: \.stableID) { movie in
                                    NavigationLink(value: movie) {
                                        MovieCardView(movie: movie)
                                            .matchedTransitionSource(id: movie.stableID, in: zoomNamespace)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button("Quitar de Favoritos", systemImage: "heart.slash", role: .destructive) {
                                            viewModel.removeFavorite(movie: movie, store: favoritesStore)
                                        }
                                    }
                                    .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                        .scrollIndicators(.hidden)
                    }
                }
                .padding(.top)
                .animation(.smooth, value: favoriteList.map(\.stableID))
            }
            .navigationTitle("Favoritos")
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie)
                    .navigationTransition(.zoom(sourceID: movie.stableID, in: zoomNamespace))
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    FavoritesView()
        .environment(FavoritesStore(container: FavoritesStore.inMemoryContainer()))
}

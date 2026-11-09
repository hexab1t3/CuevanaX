//
//  BuscarView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI

struct FindView: View {
    @State private var viewModel = FindViewModel()
    @Namespace private var zoomNamespace

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Buscar Películas")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal)

                    searchField

                    Group {
                        switch viewModel.state {
                        case .idle:
                            StatusMessageView(
                                icon: "sparkle.magnifyingglass",
                                title: "Busca una película",
                                message: "Escribe un título para buscar en todo el catálogo de TMDB."
                            )
                        case .loading:
                            ProgressView("Buscando...")
                                .tint(Theme.amber)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case .empty:
                            StatusMessageView(
                                icon: "magnifyingglass",
                                title: "Sin resultados para \"\(viewModel.searchText)\"",
                                message: "Prueba con otro título."
                            )
                        case .error(let message):
                            StatusMessageView(
                                icon: "wifi.exclamationmark",
                                title: "No pudimos completar la búsqueda",
                                message: message,
                                buttonTitle: "Reintentar"
                            ) {
                                Task { await viewModel.retry() }
                            }
                        case .results(let movies):
                            resultsList(movies)
                        }
                    }
                    .transition(.opacity)
                }
                .padding(.top)
                .animation(.smooth, value: viewModel.state)
            }
            .navigationTitle("Buscar")
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie)
                    .navigationTransition(.zoom(sourceID: movie.id, in: zoomNamespace))
            }
        }
        .preferredColorScheme(.dark)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Escribe el nombre de la película...", text: $viewModel.searchText)
                .foregroundStyle(.white)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .transition(.scale.combined(with: .opacity))
                .accessibilityLabel("Borrar búsqueda")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassEffect(.regular.interactive(), in: .capsule)
        .padding(.horizontal)
        .animation(.snappy, value: viewModel.searchText.isEmpty)
    }

    private func resultsList(_ movies: [Movie]) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(movies) { movie in
                    NavigationLink(value: movie) {
                        resultRow(movie)
                    }
                    .buttonStyle(.plain)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.4)
                            .scaleEffect(phase.isIdentity ? 1 : 0.96)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
    }

    private func resultRow(_ movie: Movie) -> some View {
        HStack(spacing: 14) {
            Color.clear
                .frame(width: 64, height: 96)
                .overlay {
                    MovieImageView(url: movie.posterURL)
                }
                .clipShape(.rect(cornerRadius: 12))
                .matchedTransitionSource(id: movie.id, in: zoomNamespace)

            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(String(movie.year))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                RatingBadge(rating: movie.qualification)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.bold())
                .foregroundStyle(.tertiary)
        }
        .padding(10)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 20))
        .contentShape(.rect(cornerRadius: 20))
    }
}

#Preview {
    FindView()
        .environment(FavoritesStore(container: FavoritesStore.inMemoryContainer()))
}

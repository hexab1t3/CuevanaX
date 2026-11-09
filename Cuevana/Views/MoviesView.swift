//
//  PeliculasView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI
import WaterfallGrid

struct MoviesView: View {

    @State private var viewModel: MoviesViewModel
    @State private var featuredID: Movie.ID?
    @Namespace private var zoomNamespace

    private let featuredCount = 5

    init(viewModel: MoviesViewModel = MoviesViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                switch viewModel.state {
                case .idle, .loading:
                    loadingView
                        .transition(.opacity)
                case .content(let movies):
                    contentView(movies: movies)
                        .transition(.opacity)
                case .empty:
                    StatusMessageView(
                        icon: "film.stack",
                        title: "No hay películas por ahora",
                        message: "La consulta fue exitosa, pero TMDB no devolvió resultados.",
                        buttonTitle: "Actualizar",
                        action: retry
                    )
                    .transition(.opacity)
                case .error(let message):
                    StatusMessageView(
                        icon: "wifi.exclamationmark",
                        title: "No pudimos cargar las películas",
                        message: message,
                        buttonTitle: "Reintentar",
                        action: retry
                    )
                    .transition(.opacity)
                }
            }
            .animation(.smooth, value: viewModel.state)
            .navigationTitle("Películas")
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie)
                    .navigationTransition(.zoom(sourceID: movie.id, in: zoomNamespace))
            }
            .task {
                await viewModel.loadIfNeeded()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func retry() {
        Task { await viewModel.retry() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("CUEVANAX")
                .font(.caption.weight(.heavy))
                .tracking(3)
                .foregroundStyle(Theme.brandGradient)

            Text("Películas en Cartelera")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
        }
    }

    private var loadingView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                HStack(spacing: 10) {
                    ProgressView()
                        .tint(Theme.amber)
                    Text("Cargando películas...")
                        .foregroundStyle(.secondary)
                }

                skeleton(height: 210, cornerRadius: 28)

                HStack(alignment: .top, spacing: 14) {
                    VStack(spacing: 14) {
                        skeleton(height: 250)
                        skeleton(height: 170)
                    }
                    VStack(spacing: 14) {
                        skeleton(height: 170)
                        skeleton(height: 250)
                    }
                }
            }
            .padding()
        }
        .scrollDisabled(true)
    }

    private func skeleton(height: CGFloat, cornerRadius: CGFloat = 20) -> some View {
        ShimmerView()
            .frame(height: height)
            .clipShape(.rect(cornerRadius: cornerRadius))
    }

    private func contentView(movies: [Movie]) -> some View {
        let featured = Array(movies.prefix(featuredCount))
        let popular = Array(movies.dropFirst(featuredCount))

        return ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                    .padding(.horizontal)

                // 1. CARRUSEL DE DESTACADAS
                featuredCarousel(featured)

                Text("Películas Populares")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal)

                // 2. GRID TIPO PINTEREST
                WaterfallGrid(popular) { movie in
                    NavigationLink(value: movie) {
                        // Mezcla pósters y escenas para variar la altura de las tarjetas
                        MovieCardView(movie: movie, style: (movie.tmdbId ?? 0) % 3 == 0 ? .scene : .poster)
                            .matchedTransitionSource(id: movie.id, in: zoomNamespace)
                    }
                    .buttonStyle(.plain)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                            .scaleEffect(phase.isIdentity ? 1 : 0.94)
                    }
                }
                .gridStyle(
                    columnsInPortrait: 2,
                    columnsInLandscape: 3,
                    spacing: 14
                )
                .padding(.horizontal)

                // 3. PAGINACIÓN
                loadMoreFooter
            }
            .padding(.vertical)
        }
        .scrollIndicators(.hidden)
    }

    private func featuredCarousel(_ featured: [Movie]) -> some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 14) {
                    ForEach(Array(featured.enumerated()), id: \.element.id) { index, movie in
                        NavigationLink(value: movie) {
                            featuredCard(movie, rank: index + 1)
                                .matchedTransitionSource(id: movie.id, in: zoomNamespace)
                        }
                        .buttonStyle(.plain)
                        .containerRelativeFrame(.horizontal)
                        .scrollTransition { content, phase in
                            content
                                .scaleEffect(phase.isIdentity ? 1 : 0.9)
                                .opacity(phase.isIdentity ? 1 : 0.6)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, 16, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $featuredID)
            .scrollIndicators(.hidden)

            HStack(spacing: 6) {
                ForEach(featured) { movie in
                    let isCurrent = movie.id == (featuredID ?? featured.first?.id)
                    Capsule()
                        .fill(isCurrent ? Theme.amber : .white.opacity(0.3))
                        .frame(width: isCurrent ? 20 : 6, height: 6)
                }
            }
            .frame(maxWidth: .infinity)
            .animation(.snappy, value: featuredID)
        }
    }

    private func featuredCard(_ movie: Movie, rank: Int) -> some View {
        Color.clear
            .aspectRatio(16 / 10, contentMode: .fit)
            .overlay {
                MovieImageView(url: movie.backdropURL ?? movie.posterURL)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(movie.title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        RatingBadge(rating: movie.qualification)
                        Text(String(movie.year))
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .padding(.top, 40)
                .background(Theme.imageShade)
            }
            .overlay(alignment: .topLeading) {
                Text("#\(rank) EN TENDENCIA")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .glassEffect(.regular.tint(Theme.coral.opacity(0.5)), in: .capsule)
                    .padding(12)
            }
            .clipShape(.rect(cornerRadius: 28))
            .contentShape(.rect(cornerRadius: 28))
            .shadow(color: .black.opacity(0.4), radius: 16, y: 10)
    }

    private var loadMoreFooter: some View {
        VStack(spacing: 8) {
            if viewModel.isLoadingMore {
                ProgressView()
                    .tint(Theme.amber)
            } else {
                if let message = viewModel.loadMoreErrorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(Theme.coral)
                        .multilineTextAlignment(.center)
                }
                Button {
                    Task { await viewModel.loadMoreMovies() }
                } label: {
                    Label(
                        viewModel.loadMoreErrorMessage == nil ? "Cargar más" : "Reintentar",
                        systemImage: viewModel.loadMoreErrorMessage == nil ? "chevron.down" : "arrow.clockwise"
                    )
                    .font(.headline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.glass)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}

#if DEBUG
private struct PreviewMovieService: MovieServiceProtocol {
    enum Mode { case content, empty, failure }
    let mode: Mode

    func fetchPopularMovies(page: Int) async throws -> [Movie] {
        switch mode {
        case .content: return ExampleMovies
        case .empty: return []
        case .failure: throw NetworkError.httpError(statusCode: 500)
        }
    }

    func searchMovies(query: String) async throws -> [Movie] {
        try await fetchPopularMovies(page: 1)
    }
}

#Preview("Content") {
    MoviesView(viewModel: MoviesViewModel(service: PreviewMovieService(mode: .content)))
        .environment(FavoritesStore(container: FavoritesStore.inMemoryContainer()))
}

#Preview("Empty") {
    MoviesView(viewModel: MoviesViewModel(service: PreviewMovieService(mode: .empty)))
        .environment(FavoritesStore(container: FavoritesStore.inMemoryContainer()))
}

#Preview("Error") {
    MoviesView(viewModel: MoviesViewModel(service: PreviewMovieService(mode: .failure)))
        .environment(FavoritesStore(container: FavoritesStore.inMemoryContainer()))
}
#endif

//
//  DetallePeliculaView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI

struct MovieDetailView: View {
    @Environment(FavoritesStore.self) var favoritesStore
    @State private var viewModel: MovieDetailViewModel

    init(movie: Movie) {
        _viewModel = State(initialValue: MovieDetailViewModel(movie: movie))
    }

    var body: some View {
        let isFavorite = viewModel.isFavorite(favoritesStore: favoritesStore)

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // 1. Póster que se desvanece hacia el fondo
                Color.clear
                    .containerRelativeFrame(.vertical) { height, _ in
                        height * 0.62
                    }
                    .overlay {
                        MovieImageView(url: viewModel.movie.posterURL)
                    }
                    .clipped()
                    .mask {
                        LinearGradient(
                            stops: [
                                .init(color: .black, location: 0.55),
                                .init(color: .clear, location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }

                VStack(alignment: .leading, spacing: 18) {
                    // 2. Título de la película
                    Text(viewModel.movie.title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 8)

                    // 3. Metadatos en chips de vidrio
                    GlassEffectContainer(spacing: 8) {
                        HStack(spacing: 8) {
                            infoChip(icon: "calendar", text: String(viewModel.movie.year))
                            infoChip(icon: "film", text: viewModel.movie.gender)
                            infoChip(icon: "star.fill", text: viewModel.formattedRating, iconColor: Theme.amber)
                        }
                    }

                    // 4. Botón de Favoritos
                    Button {
                        viewModel.toggleFavorite(favoritesStore: favoritesStore)
                    } label: {
                        Label(viewModel.buttonTitle(isFavorite: isFavorite), systemImage: isFavorite ? "heart.fill" : "heart")
                            .font(.headline)
                            .foregroundStyle(isFavorite ? Color.white : Color.black)
                            .contentTransition(.symbolEffect(.replace))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(isFavorite ? Theme.coral : Theme.amber)
                    .sensoryFeedback(.success, trigger: isFavorite)
                    .animation(.smooth, value: isFavorite)

                    // 5. Sinopsis
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sinopsis")
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text(viewModel.movie.sinopsis)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.85))
                            .lineSpacing(4)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassEffect(.regular, in: .rect(cornerRadius: 24))
                }
                .padding(.horizontal, 20)
                .padding(.top, -120)
                .padding(.bottom, 40)
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .background {
            backdrop
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    // Fondo con la película desenfocada para que la pantalla tome sus colores
    private var backdrop: some View {
        Color.clear
            .overlay {
                MovieImageView(url: viewModel.movie.backdropURL ?? viewModel.movie.posterURL)
                    .blur(radius: 50, opaque: true)
            }
            .overlay {
                LinearGradient(
                    colors: [Theme.background.opacity(0.3), Theme.background.opacity(0.85), Theme.background],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
    }

    private func infoChip(icon: String, text: String, iconColor: Color = .white) -> some View {
        Label {
            Text(text)
                .foregroundStyle(.white)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
        }
        .font(.subheadline.weight(.semibold))
        .lineLimit(1)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .glassEffect(.regular, in: .capsule)
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movie: ExampleMovies[0])
    }
    .environment(FavoritesStore(container: FavoritesStore.inMemoryContainer()))
    .preferredColorScheme(.dark)
}

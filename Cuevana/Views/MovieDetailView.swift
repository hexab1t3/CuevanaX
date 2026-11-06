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
            VStack(spacing: 20) {
                
                // 1. Sustituimos el icono por el póster real usando AsyncImage
                AsyncImage(url: viewModel.movie.posterURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(2/3, contentMode: .fit)
                        .overlay(ProgressView())
                }
                .frame(height: 350)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                .padding(.top)

                // 2. Título de la película
                Text(viewModel.movie.title)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // 3. Metadatos formateados provistos por el ViewModel
                Text(viewModel.formattedMetadata)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // 4. Sinopsis
                Text(viewModel.movie.sinopsis)
                    .font(.body)
                    .padding()
                    .multilineTextAlignment(.center)

                // 5. Botón de Favoritos
                Button(action: {
                    viewModel.toggleFavorite(favoritesStore: favoritesStore)
                }) {
                    Text(viewModel.buttonTitle(isFavorite: isFavorite))
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isFavorite ? Color.red : Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }
}

#Preview {
    MovieDetailView(movie: ExampleMovies[0])
        .environment(FavoritesStore(container: FavoritesStore.inMemoryContainer()))
}

//
//  BuscarView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI

struct FindView: View {
    @State private var viewModel = FindViewModel()

    // Colores personalizados del tema
    private let deepNavyBackground = Color(red: 0.04, green: 0.06, blue: 0.12)
    private let cardBackground = Color(red: 0.08, green: 0.12, blue: 0.20)
    private let amberAccent = Color(red: 1.0, green: 0.75, blue: 0.0)

    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo azul marino profundo
                deepNavyBackground
                    .ignoresSafeArea()

                VStack {
                    Text("Buscar Películas")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding()

                    TextField("Escribe el nombre de la película...", text: $viewModel.searchText)
                        .padding()
                        .background(cardBackground)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)

                    Spacer()

                    if viewModel.filteredMovies.isEmpty {
                        VStack(spacing: 20) {
                            Text("🍿")
                                .font(.system(size: 80))
                            Text("Busca una película")
                                .foregroundColor(.gray)
                        }
                    } else {
                        List(viewModel.filteredMovies) { movie in
                            NavigationLink(value: movie) {
                                HStack(spacing: 12) {
                                    // Miniatura del póster
                                    AsyncImage(url: movie.posterURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.3)
                                    }
                                    .frame(width: 45, height: 70)
                                    .cornerRadius(6)
                                    .clipped()

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(movie.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        // Estrellita en color ámbar
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
                        .scrollContentBackground(.hidden)
                    }

                    Spacer()
                }
            }
            .navigationTitle("Buscar")
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    FindView()
        .environment(FavoritesStore(container: FavoritesStore.inMemoryContainer()))
}

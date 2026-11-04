//
//  PerfilView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//
import SwiftUI

struct ProfileView: View {
    @Binding var isAuthenticated: Bool
    @Environment(FavoritesStore.self) var favoritesStore
    @State private var viewModel = ProfileViewModel()

    // Colores personalizados del tema
    private let deepNavyBackground = Color(red: 0.04, green: 0.06, blue: 0.12)
    private let cardBackground = Color(red: 0.08, green: 0.12, blue: 0.20)
    private let amberAccent = Color(red: 1.0, green: 0.75, blue: 0.0)

    var body: some View {
        ZStack {
            // Fondo azul marino profundo
            deepNavyBackground
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Perfil")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding()

                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(amberAccent) // Toque elegante en ámbar para el icono de perfil

                VStack(spacing: 10) {
                    Text(viewModel.username)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text(viewModel.email)
                        .foregroundColor(.gray)
                    
                    Text("Favoritas: \(viewModel.favoritesCount(favoritesStore: favoritesStore))")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(cardBackground)
                .cornerRadius(12)
                .padding(.horizontal, 24)

                Button(action: {
                    viewModel.logout(isAuthenticated: &isAuthenticated)
                }) {
                    Text("Cerrar Sesión")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ProfileView(isAuthenticated: .constant(true))
        .environment(FavoritesStore(container: FavoritesStore.inMemoryContainer()))
}

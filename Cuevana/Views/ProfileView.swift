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

    var body: some View {
        let favoritesCount = viewModel.favoritesCount(favoritesStore: favoritesStore)

        ZStack {
            AmbientBackground()

            ScrollView {
                VStack(spacing: 28) {
                    Text("Perfil")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 12) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.white)
                            .frame(width: 110, height: 110)
                            .glassEffect(.regular.tint(Theme.violet.opacity(0.35)), in: .circle)
                            .overlay {
                                Circle()
                                    .strokeBorder(Theme.brandGradient, lineWidth: 3)
                            }

                        Text(viewModel.username)
                            .font(.title2.bold())
                            .foregroundStyle(.white)

                        Text(viewModel.email)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 16) {
                        Image(systemName: "heart.fill")
                            .font(.title)
                            .foregroundStyle(Theme.brandGradient)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Favoritas")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("Películas guardadas")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("\(favoritesCount)")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                            .contentTransition(.numericText(value: Double(favoritesCount)))
                    }
                    .padding(20)
                    .glassEffect(.regular, in: .rect(cornerRadius: 24))
                    .animation(.smooth, value: favoritesCount)

                    Button {
                        withAnimation(.smooth) {
                            viewModel.logout(isAuthenticated: &isAuthenticated)
                        }
                    } label: {
                        Label("Cerrar Sesión", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.red.opacity(0.8))
                }
                .padding(.horizontal, 24)
                .padding(.vertical)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ProfileView(isAuthenticated: .constant(true))
        .environment(FavoritesStore(container: FavoritesStore.inMemoryContainer()))
}

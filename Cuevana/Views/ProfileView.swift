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
        VStack(spacing: 30) {
            Text("Perfil")
                .font(.title2)
                .bold()
                .padding()

            Image(systemName: "person.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.gray)

            VStack(spacing: 10) {
                Text("Usuario")
                    .font(.title3)
                    .bold()
                Text("usuario@ejemplo.com")
                    .foregroundColor(.gray)
                Text("Favoritas: \(favoritesStore.ids.count)")
                    .font(.subheadline)
            }
	
            Button(action: {
                viewModel.logout(isAuthenticated: &isAuthenticated)
            }) {
                Text("Cerrar Sesión")
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
}

#Preview {
    ProfileView(isAuthenticated: .constant(true))
        .environment(FavoritesStore())
}


//
//  LoginView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @State private var viewModel = LoginViewModel()

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "film.stack")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text("CuevanaX")
                .font(.largeTitle)
                .bold()

            VStack(spacing: 15) {
                TextField("Correo electrónico", text: $viewModel.mail)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Contraseña", text: $viewModel.password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Button(action: {
                viewModel.login(isAuthenticated: &isAuthenticated)
            }) {
                Text("Iniciar Sesión")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer()
        }
    }
}

#Preview {
    LoginView(isAuthenticated: .constant(false))
}

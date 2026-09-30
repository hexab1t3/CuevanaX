//
//  PerfilView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI

struct PerfilView: View {
    @Binding var estaAutenticado: Bool

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
            }

            Button(action: {
                estaAutenticado = false
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
    PerfilView(estaAutenticado: .constant(true))
}


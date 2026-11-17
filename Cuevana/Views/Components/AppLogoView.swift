//
//  AppLogoView.swift
//  Cuevana
//

import SwiftUI

/// Logo de CuevanaX: la cueva en pixel art con el botón de play (imagen "CuevanaLogo" de Assets).
struct AppLogoView: View {
    var width: CGFloat = 176

    var body: some View {
        Image("CuevanaLogo")
            .interpolation(.none)      // sin suavizado: los pixeles se mantienen nítidos al cambiar de tamaño
            .resizable()
            .scaledToFit()
            .frame(width: width)
            .shadow(color: .black.opacity(0.45), radius: 18, y: 8)
            .accessibilityLabel("CuevanaX")
    }
}

#Preview {
    ZStack {
        AmbientBackground(animated: true)
        AppLogoView()
    }
}

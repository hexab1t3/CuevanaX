//
//  AppLogoView.swift
//  Cuevana
//

import SwiftUI

/// Logo de CuevanaX: una "C" con un botón de play dentro, sobre vidrio.
struct AppLogoView: View {
    var size: CGFloat = 96
    var animated = true

    @State private var arcEnd: CGFloat = 0.12
    @State private var isPlayVisible = false

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.12, to: arcEnd)
                .stroke(Theme.brandGradient, style: StrokeStyle(lineWidth: size * 0.13, lineCap: .round))

            Image(systemName: "play.fill")
                .font(.system(size: size * 0.32, weight: .black))
                .foregroundStyle(Theme.brandGradient)
                .offset(x: size * 0.03)
                .scaleEffect(isPlayVisible ? 1 : 0.3)
                .opacity(isPlayVisible ? 1 : 0)
        }
        .frame(width: size, height: size)
        .padding(size * 0.2)
        .glassEffect(.regular, in: .rect(cornerRadius: size * 0.36))
        .onAppear {
            guard animated else {
                arcEnd = 0.88
                isPlayVisible = true
                return
            }
            withAnimation(.easeOut(duration: 0.9)) {
                arcEnd = 0.88
            }
            withAnimation(.spring(duration: 0.6, bounce: 0.5).delay(0.6)) {
                isPlayVisible = true
            }
        }
        .accessibilityElement()
        .accessibilityLabel("CuevanaX")
    }
}

#Preview {
    ZStack {
        AmbientBackground(animated: true)
        AppLogoView(size: 120)
    }
}

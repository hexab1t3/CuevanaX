//
//  CuevanaApp.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI
import SwiftData

@main
struct CuevanaApp: App {
    @State private var isAuthenticated = false
    @State private var favorites = FavoritesStore()

    init() {
        // Caché más grande para no volver a descargar los pósters al regresar a una pantalla
        URLCache.shared = URLCache(memoryCapacity: 64 * 1024 * 1024, diskCapacity: 512 * 1024 * 1024)
    }

    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                MainTabView(isAuthenticated: $isAuthenticated)
                    .environment(favorites)
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
        .modelContainer(FavoritesStore.defaultContainer)
    }
}

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

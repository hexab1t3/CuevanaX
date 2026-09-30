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
    @State private var estaAutenticado = false
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    var body: some Scene {
        WindowGroup {
            if estaAutenticado {
                MainTabView(estaAutenticado: $estaAutenticado)
            } else {
                LoginView(estaAutenticado: $estaAutenticado)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

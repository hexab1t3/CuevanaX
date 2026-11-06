//
//  ProfileViewModel.swift
//  Cuevana
//
//  Created by Leonardo Alarcón García.
//

import Foundation
import Observation

@Observable
class ProfileViewModel {
    var username: String = "Usuario"
    var email: String = "usuario@ejemplo.com"
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    /// Obtiene la cantidad de películas favoritas registradas
    func favoritesCount(favoritesStore: FavoritesStore) -> Int {
        favoritesStore.ids.count
    }
    
    /// Cierra la sesión activa a través del servicio y actualiza el estado
    func logout(isAuthenticated: inout Bool) {
        authService.logout()
        isAuthenticated = false
    }
}

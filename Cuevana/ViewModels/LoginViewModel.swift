//
//  LoginViewModel.swift
//  Cuevana
//
//  Created by Leonardo Alarcón García.
//

import Foundation
import Observation

@Observable
class LoginViewModel {
    var mail = ""
    var password = ""
    var errorMessage: String? = nil
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    
    /// Valida que las credenciales cumplan los requisitos
    var isValid: Bool {
        authService.validateCredentials(email: mail, password: password)
    }
    
    /// Ejecuta la acción de inicio de sesión delegando en el AuthService
    func login(isAuthenticated: inout Bool) {
        if authService.login(email: mail, password: password) {
            isAuthenticated = true
            errorMessage = nil
        } else {
            isAuthenticated = false
            errorMessage = "Credenciales inválidas. Por favor verifique correo y contraseña."
        }
    }
}

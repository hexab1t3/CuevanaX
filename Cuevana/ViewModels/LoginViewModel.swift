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
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    /// Valida que las credenciales cumplan los requisitos
    var isValid: Bool {
        authService.validateCredentials(email: mail, password: password)
    }
    
    /// Ejecuta el proceso de inicio de sesión delegando en el AuthService
    func login(isAuthenticated: inout Bool) {
        _ = authService.login(email: mail, password: password)
        isAuthenticated = true
        errorMessage = nil
    }
}

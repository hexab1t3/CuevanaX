//
//  AuthService.swift
//  Cuevana
//
//  Created by Leonardo Alarcón García.
//

import Foundation

/// Protocolo para el servicio de autenticación
protocol AuthServiceProtocol {
    func validateCredentials(email: String, password: String) -> Bool
    func login(email: String, password: String) -> Bool
    func logout()
}

/// Servicio que gestiona la lógica de autenticación y sesión
class AuthService: AuthServiceProtocol {
    static let shared = AuthService()

    init() {}

    /// Valida que el correo y la contraseña cumplan con los requisitos mínimos
    func validateCredentials(email: String, password: String) -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedEmail.isEmpty && !trimmedPassword.isEmpty
    }

    /// Realiza el inicio de sesión si las credenciales son válidas
    func login(email: String, password: String) -> Bool {
        guard validateCredentials(email: email, password: password) else {
            return false
        }
        return true
    }

    /// Cierra la sesión activa
    func logout() {
        // En implementaciones futuras, aquí se invalidan tokens o se limpia Keychain
    }
}

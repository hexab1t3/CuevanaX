//
//  LoginViewModel.swift
//  Cuevana
//
//  Created by Leonardo Alarcón García.
//

import Foundation

@Observable
class LoginViewModel {
    var mail = ""
    var password = ""
    
    // Aquí se pueden agregar validaciones futuras si c necesitan (por ejemplo, verificar que el correo no esté vacío)
    var isValid: Bool {
        !mail.isEmpty && !password.isEmpty
    }
    
    func login(isAuthenticated: inout Bool) {
        // Lógica de inicio de sesión o validación simulada
        isAuthenticated = true
    }
}


//
//  ProfileViewModel.swift
//  Cuevana
//
//  Created by Leonardo Alarcón García.
//

import Foundation

@Observable
class ProfileViewModel {
    var username: String = "Usuario"
    var email: String = "usuario@ejemplo.com"
    
    func logout(isAuthenticated: inout Bool) {
        isAuthenticated = false
    }
}


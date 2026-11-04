//
//  RequestMethod.swift
//  Cuevana
//
//  Created by Leonardo Alarcón García.
//

import Foundation

/// Enum que define los métodos HTTP para las peticiones de red.
enum RequestMethod: String, CaseIterable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

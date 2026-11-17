//
//  NetworkError.swift
//  Cuevana
//
//  Created by Leonardo Alarcón García.
//

import Foundation

/// Representa los posibles errores ocurridos durante una petición de red.
enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case missingToken
    case connectivity(String)
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(String)
    case noData
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "La URL proporcionada no es válida."
        case .missingToken:
            return "No hay un token de TMDB configurado. Copia Secrets.plist.example como Secrets.plist y agrega tu token."
        case .connectivity(let message):
            return "No se pudo conectar con el servidor. Revisa tu conexión a internet. (\(message))"
        case .invalidResponse:
            return "Respuesta no válida del servidor."
        case .httpError(let code):
            return "Error del servidor con código de estado HTTP \(code)."
        case .decodingError(let message):
            return "Error al decodificar la respuesta: \(message)"
        case .noData:
            return "No se recibieron datos del servidor."
        case .unknown(let message):
            return message
        }
    }
}

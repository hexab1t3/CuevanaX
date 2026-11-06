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
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(String)
    case noData
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "La URL proporcionada no es válida."
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

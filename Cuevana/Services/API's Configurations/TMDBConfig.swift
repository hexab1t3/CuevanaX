//
//  TMDBConfig.swift
//  Cuevana
//
//  Created by Leonardo Alarcón García on 07/11/26.
//

import Foundation

/// Configuración centralizada para el consumo de la API de TheMovieDB (TMDB).
/// Permite desacoplar las credenciales de acceso del código fuente y del repositorio,
/// soportando múltiples vías seguras de inyección (Variables de Entorno, Info.plist, Secrets.plist).
enum TMDBConfig {
    static let host = "api.themoviedb.org"
    static let scheme = "https"
    static let defaultLanguage = "es-MX"
    static let placeholderToken = "TU_TOKEN_BEARER_AQUI"

    /// Retorna el token de autorización (Bearer Token) buscando de forma jerárquica:
    /// 1. Variable de entorno del sistema o esquema de pruebas (TMDB_BEARER_TOKEN)
    /// 2. Entrada en Info.plist de la aplicación (TMDB_BEARER_TOKEN)
    /// 3. Archivo local de credenciales no rastreado (Secrets.plist)
    /// Si no lo encuentra regresa nil y el servicio lanza NetworkError.missingToken.
    static var bearerToken: String? {
        // 1. Variable de entorno
        if let envToken = ProcessInfo.processInfo.environment["TMDB_BEARER_TOKEN"], isUsable(envToken) {
            return envToken
        }

        // 2. Info.plist
        if let bundleToken = Bundle.main.object(forInfoDictionaryKey: "TMDB_BEARER_TOKEN") as? String, isUsable(bundleToken) {
            return bundleToken
        }

        // 3. Secrets.plist (archivo ignorado en git)
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let secretToken = dict["TMDB_BEARER_TOKEN"] as? String,
           isUsable(secretToken) {
            return secretToken
        }

        return nil
    }

    private static func isUsable(_ token: String) -> Bool {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed != placeholderToken
    }
}

//
//  AppFont.swift
//  Cuevana
//
//  Fuente de la app: Pixelify Sans, descargada de Google Fonts (licencia libre OFL, ver Fonts/OFL.txt).
//  Los archivos .ttf están en la carpeta Fonts y Xcode los copia dentro de la app.
//

import SwiftUI
import CoreText

/// Registra los archivos de la fuente para poder usarlos con `Font.custom`.
enum AppFont {

    /// Por ser `static let`, este bloque se ejecuta una sola vez: la primera vez que se pide la fuente.
    static let registerFiles: Void = {
        for name in ["PixelifySans-Regular", "PixelifySans-Medium", "PixelifySans-SemiBold", "PixelifySans-Bold"] {
            if let url = Bundle.main.url(forResource: name, withExtension: "ttf") {
                _ = CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }()

    /// Archivo que corresponde al grosor pedido.
    static func fileName(for weight: Font.Weight) -> String {
        switch weight {
        case .bold, .heavy, .black: return "PixelifySans-Bold"
        case .semibold: return "PixelifySans-SemiBold"
        case .medium: return "PixelifySans-Medium"
        default: return "PixelifySans-Regular"
        }
    }

    /// Tamaño en puntos de cada estilo de texto (los mismos que usa iOS por defecto).
    static func size(for style: Font.TextStyle) -> CGFloat {
        switch style {
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline, .body: return 17
        case .callout: return 16
        case .subheadline: return 15
        case .footnote: return 13
        case .caption: return 12
        case .caption2: return 11
        default: return 17
        }
    }
}

extension Font {
    /// Pixelify Sans con el tamaño de un estilo de iOS. Ejemplo: `.font(.pixelify(.largeTitle, weight: .bold))`.
    /// Con `relativeTo` el texto crece si el usuario agranda la letra en Ajustes.
    static func pixelify(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        _ = AppFont.registerFiles
        return .custom(AppFont.fileName(for: weight), size: AppFont.size(for: style), relativeTo: style)
    }

    /// Pixelify Sans con un tamaño fijo en puntos. Ejemplo: `.font(.pixelify(size: 42, weight: .bold))`.
    static func pixelify(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        _ = AppFont.registerFiles
        return .custom(AppFont.fileName(for: weight), size: size)
    }
}

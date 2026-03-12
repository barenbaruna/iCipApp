//
//  AppColors.swift
//  iCipApp
//
//  Design System — Adaptive Color Palette (Light + Dark mode)
//  Follows Apple HIG: uses semantic system colors where appropriate
//

import SwiftUI

// MARK: - Adaptive Color Palette
struct AppColors {
    
    // MARK: - Primary — Orange (Kehangatan, Energi, Semangat)
    static let orangeMain = Color(hex: "#F5790A")
    static let orangeLight = Color(hex: "#FFA040")
    static let orangeTint = Color(light: "#FFF3E0", dark: "#3D2B12")
    
    // MARK: - Secondary — Green (Kesehatan, Kepercayaan)
    static let greenMain = Color(hex: "#4CAF50")
    static let greenSoft = Color(hex: "#A5D6A7")
    static let greenTint = Color(light: "#F1F8E9", dark: "#1B3219")
    
    // MARK: - Surface & Background (Adaptive)
    static let creamWhite = Color(light: "#FFFDF9", dark: "#1C1C1E")
    static let surfaceGray = Color(light: "#F5F5F5", dark: "#2C2C2E")
    static let cardWhite = Color(light: "#FFFFFF", dark: "#2C2C2E")
    
    // MARK: - Text (Adaptive)
    static let textDark = Color(light: "#1A1A1A", dark: "#F5F5F5")
    static let textMidGray = Color(light: "#5C5C5C", dark: "#ADADAD")
    static let textSubtleGray = Color(light: "#9E9E9E", dark: "#7C7C7C")
    
    // MARK: - Input Fields (Dark mode safe)
    static let inputBackground = Color(light: "#F5F5F5", dark: "#3A3A3C")
    static let inputText = Color(light: "#1A1A1A", dark: "#F5F5F5")
    
    // MARK: - Semantic
    static let alertRed = Color(hex: "#E53935")
    static let alertRedTint = Color(light: "#FFEBEE", dark: "#3D1516")
    static let warningYellow = Color(hex: "#FFB300")
    static let warningYellowTint = Color(light: "#FFFDE7", dark: "#3D3614")
    static let infoBlue = Color(hex: "#1E88E5")
    static let blueTint = Color(light: "#E3F2FD", dark: "#1A2A3D")
    static let purpleMain = Color(hex: "#7B1FA2")
    static let purpleTint = Color(light: "#F3E5F5", dark: "#2D1536")
    
    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "#F5790A"), Color(hex: "#FFA040")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warmGradient = LinearGradient(
        colors: [Color(light: "#FFF3E0", dark: "#3D2B12"), Color(light: "#FFFDF9", dark: "#1C1C1E")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let greenGradient = LinearGradient(
        colors: [Color(hex: "#4CAF50"), Color(hex: "#81C784")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Hex Color Extension (Light & Dark)
extension Color {
    /// Standard hex initializer (single color)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Adaptive hex initializer — different colors for light and dark mode (Apple HIG)
    init(light lightHex: String, dark darkHex: String) {
        self.init(uiColor: UIColor { traitCollection in
            let hex = traitCollection.userInterfaceStyle == .dark ? darkHex : lightHex
            let hexClean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int: UInt64 = 0
            Scanner(string: hexClean).scanHexInt64(&int)
            let r, g, b: UInt64
            switch hexClean.count {
            case 6:
                (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
            default:
                (r, g, b) = (0, 0, 0)
            }
            return UIColor(
                red: CGFloat(r) / 255,
                green: CGFloat(g) / 255,
                blue: CGFloat(b) / 255,
                alpha: 1.0
            )
        })
    }
}

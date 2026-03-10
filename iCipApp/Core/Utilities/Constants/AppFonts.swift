//
//  AppFonts.swift
//  iCipApp
//
//  Typography System — SF Pro Display / SF Pro Text
//

import SwiftUI

// MARK: - Typography
struct AppFonts {
    /// Screen Title — SF Pro Display Bold, 28pt
    static func heading1() -> Font {
        .system(size: 28, weight: .bold, design: .default)
    }
    
    /// Section Title — SF Pro Display Semibold, 22pt
    static func heading2() -> Font {
        .system(size: 22, weight: .semibold, design: .default)
    }
    
    /// Card Title — SF Pro Display Medium, 17pt
    static func heading3() -> Font {
        .system(size: 17, weight: .medium, design: .default)
    }
    
    /// Body Regular — SF Pro Text Regular, 15pt
    static func bodyRegular() -> Font {
        .system(size: 15, weight: .regular, design: .default)
    }
    
    /// Caption / Label — SF Pro Text Regular, 12pt
    static func caption() -> Font {
        .system(size: 12, weight: .regular, design: .default)
    }
    
    /// CTA Button Text — SF Pro Display Bold, 17pt
    static func ctaText() -> Font {
        .system(size: 17, weight: .bold, design: .default)
    }
    
    /// Orange Highlight Text — SF Pro Display Semibold
    static func highlight(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
    
    /// Large Display Number — for stats/metrics
    static func statNumber() -> Font {
        .system(size: 34, weight: .bold, design: .rounded)
    }
}

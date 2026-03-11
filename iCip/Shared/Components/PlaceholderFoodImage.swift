//
//  PlaceholderFoodImage.swift
//  iCipApp
//
//  Default food image for recipes without imageUrl.
//  Renders a gradient background with a food emoji based on age group.
//

import SwiftUI

// MARK: - Placeholder Food Image
struct PlaceholderFoodImage: View {
    
    // MARK: - Properties
    let ageMinimumMonths: Int
    var height: CGFloat = 120
    
    // MARK: - Body
    var body: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Premium background pattern
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: height * 1.5, height: height * 1.5)
                .offset(x: height * 0.4, y: -height * 0.3)
            
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: height, height: height)
                .offset(x: -height * 0.4, y: height * 0.4)
            
            VStack(spacing: 8) {
                Image(systemName: foodEmoji)
                    .font(.system(size: height * 0.35))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
                    
                Text(textureLabel)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
        }
        .frame(height: height)
        .accessibilityLabel("Gambar makanan placeholder")
    }
    
    // MARK: - Helpers
    private var gradientColors: [Color] {
        if ageMinimumMonths <= 8 {
            return [Color(hex: "#FF9A56"), Color(hex: "#FFCD56")]
        } else if ageMinimumMonths <= 11 {
            return [Color(hex: "#56CCF2"), Color(hex: "#2F80ED")]
        } else {
            return [Color(hex: "#6FCF97"), Color(hex: "#66D2A5")]
        }
    }
    
    private var foodEmoji: String {
        if ageMinimumMonths <= 8 { return "drop.fill" }
        else if ageMinimumMonths <= 11 { return "square.grid.2x2.fill" }
        else { return "fork.knife" }
    }
    
    private var textureLabel: String {
        if ageMinimumMonths <= 8 { return "Lumat" }
        else if ageMinimumMonths <= 11 { return "Cincang" }
        else { return "Keluarga" }
    }
}

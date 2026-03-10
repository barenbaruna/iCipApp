//
//  NutritionBadge.swift
//  iCipApp
//
//  Reusable nutrition badge component for displaying calorie/protein/fat values.
//

import SwiftUI

// MARK: - Nutrition Badge
struct NutritionBadge: View {
    
    // MARK: - Properties
    let title: String
    let value: String
    let unit: String
    let color: Color
    let bgColor: Color
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(AppFonts.caption())
                .foregroundColor(AppColors.textMidGray)
            
            HStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                Text(unit)
                    .font(.system(size: 11))
                    .foregroundColor(color.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(bgColor)
        .cornerRadius(14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value) \(unit)")
    }
}

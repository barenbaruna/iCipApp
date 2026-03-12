//
//  RecipeCardView.swift
//  iCip
//
//  Horizontal scroll recipe card with recommendation badge and nutrition chips.
//  Supports personalized "Sangat Direkomendasikan" tag from scoring engine.
//

import SwiftUI

// MARK: - Recipe Card View
struct RecipeCardView: View {
    
    // MARK: - Properties
    let recipe: RecipeItem
    let conflicts: [String]
    var recommendation: RecommendationReason?
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image with optional recommendation badge
            ZStack(alignment: .topLeading) {
                ZStack(alignment: .bottomLeading) {
                    FoodImage(imageUrl: recipe.id, ageMinimumMonths: recipe.ageMinimumMonths, height: 120)
                    
                    // Age badge (glassmorphism)
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 9))
                        Text("\(recipe.ageMinimumMonths)-\(recipe.ageMaximumMonths) bln")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .padding(10)
                }
                
                // Highly Recommended badge
                if let rec = recommendation, rec.isHighlyRecommended {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                        Text("Direkomendasikan")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        LinearGradient(
                            colors: [Color.orange, Color.red.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
                    .padding(8)
                }
            }
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 16))
            
            // Content area
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name)
                    .font(AppFonts.heading3())
                    .foregroundColor(AppColors.textDark)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Nutrition chips
                HStack(spacing: 8) {
                    nutritionChip(icon: "flame.fill", value: "\(Int(recipe.calories))", unit: "kkal", color: AppColors.orangeMain)
                    nutritionChip(icon: "drop.fill", value: String(format: "%.1f", recipe.protein), unit: "g", color: AppColors.infoBlue)
                }
                
                // Reason tag or status badge
                if let rec = recommendation {
                    reasonTag(rec)
                } else {
                    statusBadge
                }
            }
            .padding(12)
        }
        .frame(minWidth: 160, idealWidth: 200, maxWidth: 220)
        .background(AppColors.cardWhite)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - Subviews
    private func nutritionChip(icon: String, value: String, unit: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundColor(color)
            Text("\(value)\(unit)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.textMidGray)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.08))
        .cornerRadius(6)
    }
    
    private func reasonTag(_ rec: RecommendationReason) -> some View {
        HStack(spacing: 4) {
            Image(systemName: rec.icon)
                .font(.system(size: 10))
            Text(rec.tag)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundColor(rec.isHighlyRecommended ? AppColors.orangeMain : AppColors.greenMain)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(rec.isHighlyRecommended ? AppColors.orangeTint : AppColors.greenTint)
        .cornerRadius(8)
    }
    
    private var statusBadge: some View {
        Group {
            if !conflicts.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10))
                    Text("Substitusi")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(AppColors.alertRed)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppColors.alertRedTint)
                .cornerRadius(8)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                    Text("Aman")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(AppColors.greenMain)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppColors.greenTint)
                .cornerRadius(8)
            }
        }
    }
}

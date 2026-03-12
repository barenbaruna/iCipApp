//
//  GrowthStatusCard.swift
//  iCipApp
//
//  Overall growth status card — dynamic color based on worst Z-score.
//

import SwiftUI

// MARK: - Growth Status Card
struct GrowthStatusCard: View {
    
    let status: GrowthStatus
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(status.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: status.icon)
                    .font(.system(size: 22))
                    .foregroundColor(status.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Status Pertumbuhan")
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.textMidGray)
                Text(status.rawValue)
                    .font(AppFonts.heading3())
                    .foregroundColor(AppColors.textDark)
                Text(status.description)
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.textMidGray)
                    .lineSpacing(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(status.tintColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 24)
    }
}

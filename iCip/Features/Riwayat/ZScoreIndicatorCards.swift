//
//  ZScoreIndicatorCards.swift
//  iCipApp
//
//  Three mini indicator cards showing Z-score for BB/U, TB/U, BB/TB.
//  Tapping switches the chart indicator.
//

import SwiftUI

// MARK: - Z-Score Indicator Cards
struct ZScoreIndicatorCards: View {
    
    @ObservedObject var viewModel: RiwayatViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(GrowthIndicator.allCases) { indicator in
                let z = viewModel.zScore(for: indicator)
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.selectedIndicator = indicator
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    VStack(spacing: 8) {
                        Text(indicator.rawValue)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(viewModel.selectedIndicator == indicator ? .white : AppColors.textDark)
                        
                        if let z = z {
                            Text(String(format: "%+.1f", z))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(viewModel.selectedIndicator == indicator ? .white : WHOZScoreCalculator.colorForZScore(z))
                            
                            Text(WHOZScoreCalculator.labelForZScore(z))
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(viewModel.selectedIndicator == indicator ? .white.opacity(0.8) : AppColors.textSubtleGray)
                                .lineLimit(1)
                        } else {
                            Text("—")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(viewModel.selectedIndicator == indicator ? .white : AppColors.textSubtleGray)
                            Text("Belum ada data")
                                .font(.system(size: 9))
                                .foregroundColor(viewModel.selectedIndicator == indicator ? .white.opacity(0.8) : AppColors.textSubtleGray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        viewModel.selectedIndicator == indicator
                            ? AnyShapeStyle(AppColors.primaryGradient)
                            : AnyShapeStyle(AppColors.cardWhite)
                    )
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.horizontal, 24)
    }
}

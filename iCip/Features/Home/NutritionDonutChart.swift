//
//  NutritionDonutChart.swift
//  iCip
//
//  Donut chart showing ASI vs MPASI nutrition ratio.
//  Data source: Kemenkes RI MPASI guidelines.
//

import SwiftUI

// MARK: - Nutrition Donut Chart
struct NutritionDonutChart: View {
    
    // MARK: - Properties
    let asiPercentage: Double   // e.g. 0.7
    let mpasiPercentage: Double // e.g. 0.3
    let ageGroupLabel: String   // e.g. "6-8 bulan"
    
    @State private var animateChart = false
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(AppColors.orangeMain)
                    .font(.system(size: 16))
                Text("Kebutuhan Nutrisi")
                    .font(AppFonts.heading3())
                    .foregroundColor(AppColors.textDark)
            }
            
            Text("Kebutuhan nutrisi sesuai umur anak (\(ageGroupLabel))")
                .font(AppFonts.caption())
                .foregroundColor(AppColors.textMidGray)
            
            // Chart + Legend
            HStack(spacing: 24) {
                // Donut chart
                ZStack {
                    // MPASI arc (bottom layer)
                    Circle()
                        .trim(from: 0, to: animateChart ? 1.0 : 0)
                        .stroke(AppColors.greenMain, style: StrokeStyle(lineWidth: 28, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    // ASI arc (top layer)
                    Circle()
                        .trim(from: 0, to: animateChart ? asiPercentage : 0)
                        .stroke(AppColors.orangeMain, style: StrokeStyle(lineWidth: 28, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    // Center label
                    VStack(spacing: 2) {
                        Text("\(Int(mpasiPercentage * 100))%")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textDark)
                        Text("MPASI")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppColors.textMidGray)
                    }
                }
                .frame(width: 130, height: 130)
                
                // Legend
                VStack(alignment: .leading, spacing: 14) {
                    legendItem(
                        color: AppColors.orangeMain,
                        label: "ASI",
                        percentage: Int(asiPercentage * 100)
                    )
                    legendItem(
                        color: AppColors.greenMain,
                        label: "MP-ASI",
                        percentage: Int(mpasiPercentage * 100)
                    )
                    
                    // Contextual note
                    Text("Sumber: Kemenkes RI")
                        .font(.system(size: 9))
                        .foregroundColor(AppColors.textSubtleGray)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(AppColors.cardWhite)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 24)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateChart = true
            }
        }
    }
    
    // MARK: - Legend Item
    private func legendItem(color: Color, label: String, percentage: Int) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 14, height: 14)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textDark)
                Text("\(percentage)%")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
        }
    }
}

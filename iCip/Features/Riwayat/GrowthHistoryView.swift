//
//  GrowthHistoryView.swift
//  iCipApp
//
//  Growth history grouped and sorted by date.
//

import SwiftUI

// MARK: - Growth History View
struct GrowthHistoryView: View {
    
    @ObservedObject var viewModel: RiwayatViewModel
    @State private var animateCards = false
    
    var body: some View {
        let measurements = viewModel.sortedMeasurements.reversed() // Show newest first
        
        if measurements.isEmpty {
            emptyState
        } else {
            LazyVStack(spacing: 16) {
                ForEach(Array(measurements.enumerated()), id: \.element.id) { index, measurement in
                    growthEntryCard(measurement: measurement, index: index)
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 15)
                        .animation(
                            .easeOut(duration: 0.4).delay(Double(index) * 0.08),
                            value: animateCards
                        )
                }
            }
            .padding(.top, 8)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                    animateCards = true
                }
            }
        }
    }
    
    // MARK: - Growth Entry Card
    private func growthEntryCard(measurement: GrowthMeasurement, index: Int) -> some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.primaryGradient)
                    .frame(width: 48, height: 48)
                Image(systemName: "ruler.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(formattedDate(measurement.date))
                    .font(AppFonts.heading3())
                    .foregroundColor(AppColors.textDark)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "scalemass.fill")
                            .font(.system(size: 10))
                        Text("\(String(format: "%.1f", measurement.weightKg)) kg")
                            .font(AppFonts.bodyRegular())
                    }
                    .foregroundColor(AppColors.greenMain)
                    
                    Text("•")
                        .foregroundColor(AppColors.textSubtleGray)
                        
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.and.down")
                            .font(.system(size: 10))
                        Text("\(String(format: "%.1f", measurement.heightCm)) cm")
                            .font(AppFonts.bodyRegular())
                    }
                    .foregroundColor(AppColors.infoBlue)
                }
            }
            
            Spacer()
            
            if index == 0 {
                Text("Terbaru")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppColors.orangeMain)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.orangeTint)
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(AppColors.cardWhite)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 40)
            
            ZStack {
                Circle()
                    .fill(AppColors.surfaceGray)
                    .frame(width: 100, height: 100)
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 48))
                    .foregroundColor(AppColors.textSubtleGray)
            }
            
            Text("Belum ada riwayat pertumbuhan")
                .font(AppFonts.heading3())
                .foregroundColor(AppColors.textMidGray)
            
            Text("Mulai ukur dan catat BB & TB si kecil\nsetiap bulannya.")
                .font(AppFonts.caption())
                .foregroundColor(AppColors.textSubtleGray)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
            
            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Helpers
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}

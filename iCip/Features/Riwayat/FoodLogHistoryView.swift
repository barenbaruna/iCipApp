//
//  FoodLogHistoryView.swift
//  iCipApp
//
//  Food log history grouped by date.
//

import SwiftUI

// MARK: - Food Log History View
struct FoodLogHistoryView: View {
    
    @ObservedObject var viewModel: RiwayatViewModel
    @State private var animateCards = false
    
    var body: some View {
        let groupedLogs = viewModel.foodLogsByDate
        
        if groupedLogs.isEmpty {
            emptyState
        } else {
            LazyVStack(spacing: 20) {
                ForEach(Array(groupedLogs.enumerated()), id: \.offset) { groupIndex, group in
                    VStack(alignment: .leading, spacing: 10) {
                        // Date header
                        Text(formattedDate(group.date))
                            .font(AppFonts.heading3())
                            .foregroundColor(AppColors.textDark)
                            .padding(.horizontal, 24)
                        
                        // Meal entries
                        ForEach(Array(group.logs.enumerated()), id: \.element.id) { logIndex, log in
                            mealEntryCard(log: log)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 15)
                                .animation(
                                    .easeOut(duration: 0.4).delay(Double(groupIndex * 3 + logIndex) * 0.06),
                                    value: animateCards
                                )
                        }
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                    animateCards = true
                }
            }
        }
    }
    
    // MARK: - Meal Entry Card
    private func mealEntryCard(log: FoodLog) -> some View {
        Button(action: {
            viewModel.selectedFoodLog = log
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            HStack(spacing: 14) {
                // Meal type icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(mealTypeColor(log.mealType).opacity(0.12))
                        .frame(width: 42, height: 42)
                    Image(systemName: mealTypeIcon(log.mealType))
                        .font(.system(size: 18))
                        .foregroundColor(mealTypeColor(log.mealType))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(log.mealType)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(mealTypeColor(log.mealType))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(mealTypeColor(log.mealType).opacity(0.1))
                            .cornerRadius(6)
                        
                        if log.isAllergyFlagged {
                            HStack(spacing: 2) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 8))
                                Text("Alergi")
                                    .font(.system(size: 9, weight: .medium))
                            }
                            .foregroundColor(AppColors.alertRed)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppColors.alertRedTint)
                            .cornerRadius(6)
                        }
                    }
                    
                    Text(log.foodName.isEmpty ? "Makanan" : log.foodName)
                        .font(AppFonts.heading3())
                        .foregroundColor(AppColors.textDark)
                        .lineLimit(1)
                    
                    if !log.nutrientHighlight.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 9))
                            Text(log.nutrientHighlight)
                                .font(.system(size: 11))
                        }
                        .foregroundColor(AppColors.greenMain)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textSubtleGray)
            }
            .padding(14)
            .background(AppColors.cardWhite)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(ScaleButtonStyle())
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
                Image(systemName: "fork.knife.circle")
                    .font(.system(size: 48))
                    .foregroundColor(AppColors.textSubtleGray)
            }
            
            Text("Belum ada catatan makanan")
                .font(AppFonts.heading3())
                .foregroundColor(AppColors.textMidGray)
            
            Text("Mulai catat makanan si kecil\nuntuk memantau asupan nutrisinya")
                .font(AppFonts.caption())
                .foregroundColor(AppColors.textSubtleGray)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Helpers
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func mealTypeIcon(_ type: String) -> String {
        switch type {
        case "Sarapan": return "sunrise.fill"
        case "Makan Siang": return "sun.max.fill"
        case "Makan Sore": return "sunset.fill"
        case "Selingan": return "cup.and.saucer.fill"
        default: return "fork.knife"
        }
    }
    
    private func mealTypeColor(_ type: String) -> Color {
        switch type {
        case "Sarapan": return AppColors.orangeMain
        case "Makan Siang": return AppColors.greenMain
        case "Makan Sore": return AppColors.infoBlue
        case "Selingan": return Color(hex: "#7B1FA2")
        default: return AppColors.textMidGray
        }
    }
}

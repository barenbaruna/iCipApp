//
//  HomeView.swift
//  iCip
//
//  Home Screen — Personalized greeting, growth status, recommendations, nutrition chart.
//  Apple HIG: Safe area, staggered animations, haptic feedback, NavigationStack.
//

import SwiftUI
import SwiftData

// MARK: - Home View
struct HomeView: View {
    
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = HomeViewModel()
    @State private var animateCards = false
    @State private var animateStats = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    greetingHeader
                    
                    if let baby = viewModel.currentBaby {
                        statusStatsCard(baby: baby)
                    }
                    
                    recommendationSection
                    
                    if viewModel.currentBaby != nil {
                        nutritionChartCard
                    }
                    
                    dailyTipCard
                    
                    Spacer(minLength: 30)
                }
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
            .background(AppColors.creamWhite.ignoresSafeArea())
            .onAppear {
                viewModel.setupConfigs(modelContext: modelContext)
                withAnimation(.easeOut(duration: 0.4).delay(0.2)) { animateStats = true }
                withAnimation(.easeOut(duration: 0.6).delay(0.3)) { animateCards = true }
            }
        }
    }
    
    // MARK: - Greeting Header
    private var greetingHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(greetingText)
                    .font(AppFonts.heading2())
                    .foregroundColor(AppColors.textMidGray)
                
                if let babyName = viewModel.currentBaby?.name {
                    Text("Menu untuk \(babyName)")
                        .font(AppFonts.heading1())
                        .foregroundColor(AppColors.textDark)
                } else {
                    Text("Menu Hari Ini")
                        .font(AppFonts.heading1())
                        .foregroundColor(AppColors.textDark)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Status + Stats Card (Combined)
    private func statusStatsCard(baby: Baby) -> some View {
        VStack(spacing: 16) {
            // Growth status badge
            statusBadge
            
            // Divider
            Rectangle()
                .fill(AppColors.surfaceGray)
                .frame(height: 1)
                .padding(.horizontal, 4)
            
            // Baby stats row
            HStack(spacing: 16) {
                statItem(
                    label: "Usia",
                    value: "\(baby.ageInMonths)",
                    unit: "bulan",
                    icon: "calendar.circle.fill",
                    color: AppColors.orangeMain
                )
                
                if let lastMeasurement = baby.measurements.sorted(by: { $0.date < $1.date }).last {
                    statItem(
                        label: "Tinggi",
                        value: String(format: "%.1f", lastMeasurement.heightCm),
                        unit: "cm",
                        icon: "ruler.fill",
                        color: AppColors.infoBlue
                    )
                    statItem(
                        label: "Berat",
                        value: String(format: "%.1f", lastMeasurement.weightKg),
                        unit: "kg",
                        icon: "scalemass.fill",
                        color: AppColors.greenMain
                    )
                }
            }
        }
        .padding(16)
        .background(AppColors.cardWhite)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 24)
        .opacity(animateStats ? 1 : 0)
        .offset(y: animateStats ? 0 : 15)
    }
    
    // MARK: - Status Badge
    private var statusBadge: some View {
        Group {
            if viewModel.hasMeasurementData {
                let status = viewModel.overallGrowthStatus
                HStack(spacing: 10) {
                    Image(systemName: status.icon)
                        .font(.system(size: 18))
                        .foregroundColor(status.color)
                    
                    Text(status.rawValue)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textDark)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(status.tintColor)
                .cornerRadius(12)
            } else {
                HStack(spacing: 10) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.textSubtleGray)
                    
                    Text("Belum ada data pengukuran")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textMidGray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppColors.surfaceGray)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Stat Item
    private func statItem(label: String, value: String, unit: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textDark)
            Text(unit)
                .font(AppFonts.caption())
                .foregroundColor(AppColors.textSubtleGray)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Recommendation Carousel
    private var recommendationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Rekomendasi Hari Ini")
                        .font(AppFonts.heading2())
                        .foregroundColor(AppColors.textDark)
                    Text("Sesuai usia & profil si kecil")
                        .font(AppFonts.caption())
                        .foregroundColor(AppColors.textMidGray)
                }
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .foregroundColor(AppColors.orangeMain)
                    .font(.system(size: 20))
                    .symbolEffect(.pulse, isActive: animateCards)
            }
            .padding(.horizontal, 24)
            
            if viewModel.recommendedRecipes.isEmpty {
                emptyStateCard
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(Array(viewModel.recommendedRecipes.enumerated()), id: \.element.id) { index, recipe in
                            let conflicts = viewModel.getConflictingAllergens(for: recipe)
                            let reason = viewModel.reason(for: recipe)
                            NavigationLink(destination: FoodDetailView(recipe: recipe, conflicts: conflicts, recommendation: reason)) {
                                RecipeCardView(recipe: recipe, conflicts: conflicts, recommendation: reason)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            })
                            .buttonStyle(ScaleButtonStyle())
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.08), value: animateCards)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private var emptyStateCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray.fill")
                .font(.system(size: 30))
                .foregroundColor(AppColors.textSubtleGray)
            Text("Belum ada rekomendasi")
                .font(AppFonts.bodyRegular())
                .foregroundColor(AppColors.textMidGray)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(AppColors.surfaceGray)
        .cornerRadius(16)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Nutrition Chart Card
    private var nutritionChartCard: some View {
        NutritionDonutChart(
            asiPercentage: viewModel.nutrisiASI,
            mpasiPercentage: viewModel.nutrisiMPASI,
            ageGroupLabel: viewModel.nutrisiAgeGroup
        )
    }
    
    // MARK: - Daily Tip
    private var dailyTipCard: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppColors.orangeTint)
                    .frame(width: 44, height: 44)
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(AppColors.orangeMain)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Tips 1000 HPK")
                    .font(AppFonts.heading3())
                    .foregroundColor(AppColors.textDark)
                Text("Pastikan selalu menjaga kebersihan tangan dan peralatan sebelum menyiapkan MPASI. Pemberian yang konsisten menurunkan risiko stunting secara signifikan.")
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.textMidGray)
                    .lineSpacing(4)
            }
        }
        .padding(16)
        .background(AppColors.orangeTint.opacity(0.6))
        .cornerRadius(16)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Helpers
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Selamat Pagi" }
        else if hour < 17 { return "Selamat Siang" }
        else { return "Selamat Sore" }
    }
}

// MARK: - Custom Button Style (Press animation)
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25), value: configuration.isPressed)
    }
}

#Preview {
    HomeView()
}

//
//  OnboardingResultSheet.swift
//  iCipApp
//
//  Celebratory result sheet shown after completing baby profile onboarding.
//  Displays Z-score analysis, nutritional targets, food recommendations,
//  and feeding schedule before navigating to the main app.
//

import SwiftUI
import SwiftData

// MARK: - Onboarding Result Sheet
struct OnboardingResultSheet: View {
    
    // MARK: - Properties
    @State private var viewModel: OnboardingResultViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var animateIn = false
    
    let profileData: BabyProfileData
    
    init(profileData: BabyProfileData) {
        self.profileData = profileData
        _viewModel = State(wrappedValue: OnboardingResultViewModel(profileData: profileData))
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    headerSection
                    growthStatusSection
                    nutrientSection
                    foodRecommendationSection
                    feedingScheduleSection
                    ctaSection
                }
                .padding(.bottom, 40)
            }
            .background(AppColors.creamWhite.ignoresSafeArea())
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) { animateIn = true }
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryGradient)
                    .frame(width: 80, height: 80)
                Image(systemName: "stethoscope")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            .scaleEffect(animateIn ? 1.0 : 0.3)
            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2), value: animateIn)
            
            Text("Halo, \(profileData.name)! 👋")
                .font(AppFonts.heading1())
                .foregroundColor(AppColors.textDark)
                .multilineTextAlignment(.center)
            
            Text("Ini hasil analisis awal tumbuh kembang si kecil")
                .font(AppFonts.bodyRegular())
                .foregroundColor(AppColors.textMidGray)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: animateIn)
    }
    
    // MARK: - Growth Status Section
    private var growthStatusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Status Pertumbuhan", icon: "chart.bar.fill")
            
            HStack(spacing: 10) {
                zScoreCard(label: "BB/U", zScore: viewModel.weightForAgeZ, delay: 0.15)
                zScoreCard(label: "TB/U", zScore: viewModel.heightForAgeZ, delay: 0.25)
                zScoreCard(label: "BB/TB", zScore: viewModel.weightForHeightZ, delay: 0.35)
            }
            .padding(.horizontal, 24)
            
            overallStatusCard
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 15)
        .animation(.easeOut(duration: 0.5).delay(0.2), value: animateIn)
    }
    
    private func zScoreCard(label: String, zScore: Double?, delay: Double) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppColors.textMidGray)
            
            if let z = zScore {
                Text(String(format: "%+.1f", z))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(WHOZScoreCalculator.colorForZScore(z))
                
                Text(WHOZScoreCalculator.labelForZScore(z))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(WHOZScoreCalculator.colorForZScore(z))
                    .cornerRadius(8)
            } else {
                Text("—")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textSubtleGray)
                Text("Data kurang")
                    .font(.system(size: 9))
                    .foregroundColor(AppColors.textSubtleGray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppColors.cardWhite)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        .scaleEffect(animateIn ? 1.0 : 0.8)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay), value: animateIn)
    }
    
    private var overallStatusCard: some View {
        let status = viewModel.overallStatus
        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(status.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: status.icon)
                    .font(.system(size: 22))
                    .foregroundColor(status.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Status Keseluruhan")
                    .font(AppFonts.caption())
                    .foregroundColor(status.color.opacity(0.8))
                Text(status.rawValue)
                    .font(AppFonts.heading3())
                    .foregroundColor(AppColors.textDark)
                Text(viewModel.contextualMessage)
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.textMidGray)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(16)
        .background(status.tintColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Nutrient Section
    private var nutrientSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Kebutuhan Nutrisi Harian", icon: "leaf.fill")
            
            VStack(spacing: 0) {
                ForEach(Array(viewModel.nutrientTargets.enumerated()), id: \.element.id) { index, nutrient in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(nutrient.isHighlighted ? AppColors.orangeTint : AppColors.surfaceGray)
                                .frame(width: 34, height: 34)
                            Image(systemName: nutrient.icon)
                                .font(.system(size: 14))
                                .foregroundColor(nutrient.isHighlighted ? AppColors.orangeMain : AppColors.textMidGray)
                        }
                        
                        Text(nutrient.name)
                            .font(AppFonts.bodyRegular())
                            .foregroundColor(nutrient.isHighlighted ? AppColors.orangeMain : AppColors.textDark)
                        
                        Spacer()
                        
                        Text(nutrient.value)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(nutrient.isHighlighted ? AppColors.orangeMain : AppColors.textMidGray)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    
                    if index < viewModel.nutrientTargets.count - 1 {
                        Divider()
                            .padding(.leading, 62)
                    }
                }
            }
            .background(AppColors.cardWhite)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 24)
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 15)
        .animation(.easeOut(duration: 0.5).delay(0.3), value: animateIn)
    }
    
    // MARK: - Food Recommendation Section
    private var foodRecommendationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Rekomendasi Menu Awal", icon: "fork.knife")
            
            if viewModel.recommendedRecipes.isEmpty {
                Text("Belum ada rekomendasi menu untuk usia ini")
                    .font(AppFonts.bodyRegular())
                    .foregroundColor(AppColors.textMidGray)
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(AppColors.surfaceGray)
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(Array(viewModel.recommendedRecipes.enumerated()), id: \.element.id) { index, recipe in
                            NavigationLink(destination: FoodDetailView(recipe: recipe, conflicts: [])) {
                                foodRecCard(recipe: recipe)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .opacity(animateIn ? 1 : 0)
                            .offset(y: animateIn ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(0.35 + Double(index) * 0.08), value: animateIn)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private func foodRecCard(recipe: RecipeItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            FoodImage(imageUrl: recipe.id, ageMinimumMonths: recipe.ageMinimumMonths, height: 100)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 14, bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0, topTrailingRadius: 14
                    )
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textDark)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(viewModel.benefitTag(for: recipe))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppColors.orangeMain)
                    .lineLimit(1)
                
                Text(viewModel.ageBadge(for: recipe))
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppColors.orangeMain)
                    .cornerRadius(8)
            }
            .padding(10)
        }
        .frame(width: 160)
        .background(AppColors.cardWhite)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
    
    // MARK: - Feeding Schedule Section
    private var feedingScheduleSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Frekuensi Makan", icon: "clock.fill")
            
            HStack(spacing: 10) {
                ForEach(Array(viewModel.feedingSchedules.enumerated()), id: \.element.id) { index, schedule in
                    let isCurrent = index == viewModel.currentFeedingIndex
                    
                    VStack(spacing: 8) {
                        Image(systemName: schedule.icon)
                            .font(.system(size: 22))
                            .foregroundColor(isCurrent ? AppColors.orangeMain : AppColors.textSubtleGray)
                        
                        Text(schedule.ageRange)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(isCurrent ? AppColors.orangeMain : AppColors.textDark)
                        
                        Text(schedule.texture)
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textMidGray)
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 2) {
                            Text(schedule.mealCount)
                                .font(.system(size: 10, weight: .semibold))
                            Text(schedule.snackCount)
                                .font(.system(size: 9))
                        }
                        .foregroundColor(isCurrent ? AppColors.orangeMain : AppColors.textSubtleGray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isCurrent ? AppColors.orangeTint : AppColors.surfaceGray)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isCurrent ? AppColors.orangeMain : Color.clear, lineWidth: 1.5)
                    )
                }
            }
            .padding(.horizontal, 24)
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 15)
        .animation(.easeOut(duration: 0.5).delay(0.4), value: animateIn)
    }
    
    // MARK: - CTA Section
    private var ctaSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "rocket.fill")
                    Text("Mulai Perjalanan MPASI 🚀")
                        .font(AppFonts.ctaText())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColors.primaryGradient)
                .cornerRadius(12)
                .shadow(color: AppColors.orangeMain.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            Button(action: {
                dismiss()
            }) {
                Text("Simpan & Lihat Nanti")
                    .font(AppFonts.bodyRegular())
                    .foregroundColor(AppColors.orangeMain)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 15)
        .animation(.easeOut(duration: 0.5).delay(0.45), value: animateIn)
    }
    
    // MARK: - Reusable Components
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(AppColors.orangeMain)
                .font(.system(size: 14))
            Text(title)
                .font(AppFonts.heading2())
                .foregroundColor(AppColors.textDark)
        }
        .padding(.horizontal, 24)
    }
}

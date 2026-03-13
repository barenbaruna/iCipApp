//
//  OnboardingResultView.swift
//  iCipApp
//
//  Celebratory result sheet — Hasil Analisis Si Kecil
//  Shown once after completing baby profile onboarding.
//

import SwiftUI

// MARK: - Onboarding Result View
struct OnboardingResultView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: OnboardingResultViewModel
    @State private var animateIn = false
    
    let onDismiss: () -> Void
    
    // MARK: - Init
    init(baby: Baby, onDismiss: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: OnboardingResultViewModel(baby: baby))
        self.onDismiss = onDismiss
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                headerSection
                growthStatusSection
                nutritionSection
                foodRecommendationSection
                feedingScheduleSection
                ctaSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .background(AppColors.creamWhite.ignoresSafeArea())
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { animateIn = true }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Baby avatar placeholder
            ZStack {
                Circle()
                    .fill(AppColors.orangeTint)
                    .frame(width: 80, height: 80)
                Image(systemName: "face.smiling.inverse")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.orangeMain)
            }
            .scaleEffect(animateIn ? 1.0 : 0.3)
            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: animateIn)
            
            VStack(spacing: 6) {
                Text("Halo, \(viewModel.baby.name)! 👋")
                    .font(AppFonts.heading1())
                    .foregroundColor(AppColors.textDark)
                    .multilineTextAlignment(.center)
                
                Text("Ini hasil analisis awal tumbuh kembang si kecil")
                    .font(AppFonts.bodyRegular())
                    .foregroundColor(AppColors.textMidGray)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: animateIn)
    }
    
    // MARK: - Section 1: Growth Status
    private var growthStatusSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Status Pertumbuhan", icon: "chart.bar.fill")
            
            // 3 indicator cards
            HStack(spacing: 10) {
                ForEach(GrowthIndicator.allCases) { indicator in
                    indicatorCard(for: indicator)
                }
            }
            
            // Overall summary card
            overallStatusCard
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.2), value: animateIn)
    }
    
    private func indicatorCard(for indicator: GrowthIndicator) -> some View {
        let z = viewModel.zScore(for: indicator)
        
        return VStack(spacing: 8) {
            Text(indicator.rawValue)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppColors.textMidGray)
            
            if let z = z {
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
                Text("N/A")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(AppColors.textSubtleGray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppColors.cardWhite)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
    
    private var overallStatusCard: some View {
        let status = viewModel.overallStatus
        
        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(status.color.opacity(0.2))
                    .frame(width: 48, height: 48)
                Image(systemName: status.icon)
                    .font(.system(size: 22))
                    .foregroundColor(status.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(status.rawValue)
                    .font(AppFonts.heading3())
                    .foregroundColor(AppColors.textDark)
                Text(viewModel.contextualMessage)
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.textMidGray)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(status.tintColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Section 2: Nutrition Targets
    private var nutritionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Kebutuhan Nutrisi Harian", icon: "leaf.fill")
            
            VStack(spacing: 0) {
                ForEach(Array(viewModel.nutrientTargets.enumerated()), id: \.element.id) { index, nutrient in
                    nutrientRow(nutrient: nutrient)
                    
                    if index < viewModel.nutrientTargets.count - 1 {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(AppColors.cardWhite)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.3), value: animateIn)
    }
    
    private func nutrientRow(nutrient: NutrientTarget) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(nutrient.isCritical ? AppColors.orangeTint : AppColors.surfaceGray)
                    .frame(width: 36, height: 36)
                Image(systemName: nutrient.icon)
                    .font(.system(size: 14))
                    .foregroundColor(nutrient.isCritical ? AppColors.orangeMain : AppColors.textMidGray)
            }
            
            Text(nutrient.name)
                .font(AppFonts.bodyRegular())
                .foregroundColor(AppColors.textDark)
            
            Spacer()
            
            HStack(spacing: 4) {
                if nutrient.isCritical {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.orangeMain)
                }
                Text(nutrient.value)
                    .font(AppFonts.highlight())
                    .foregroundColor(nutrient.isCritical ? AppColors.orangeMain : AppColors.textDark)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(nutrient.isCritical ? AppColors.orangeTint.opacity(0.3) : Color.clear)
    }
    
    // MARK: - Section 3: Food Recommendations
    private var foodRecommendationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                title: viewModel.isComplementaryFeedingAge ? "Rekomendasi Menu Awal" : "Kesiapan MPASI",
                icon: "fork.knife")

            if viewModel.foodRecommendations.isEmpty {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: viewModel.ageInMonths < 6 ? "info.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(viewModel.ageInMonths < 6 ? AppColors.infoBlue : AppColors.warningYellow)

                    Text(viewModel.foodRecommendationNotice)
                        .font(AppFonts.caption())
                        .foregroundColor(AppColors.textMidGray)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)

                    Spacer(minLength: 0)
                }
                .padding(14)
                .background(viewModel.ageInMonths < 6 ? AppColors.blueTint : AppColors.warningYellowTint)
                .cornerRadius(12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(viewModel.foodRecommendations) { food in
                            foodCard(food: food)
                        }
                    }
                }
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.4), value: animateIn)
    }
    
    private func foodCard(food: FoodRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Food image placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.orangeTint)
                    .frame(height: 80)
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.orangeMain.opacity(0.6))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(food.name)
                    .font(AppFonts.heading3())
                    .foregroundColor(AppColors.textDark)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(food.benefitTag)
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.orangeMain)
                    .lineLimit(1)
                
                Text(food.ageBadge)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(AppColors.greenMain)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppColors.greenTint)
                    .cornerRadius(6)
            }
        }
        .frame(width: 180)
        .padding(12)
        .background(AppColors.cardWhite)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Section 4: Feeding Schedule
    private var feedingScheduleSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Frekuensi Makan", icon: "clock.fill")
            
            ForEach(viewModel.feedingSchedules) { schedule in
                VStack(spacing: 12) {
                    HStack {
                        Text(schedule.ageRange)
                            .font(AppFonts.heading3())
                            .foregroundColor(AppColors.textDark)
                        Spacer()
                    }
                    
                    HStack(spacing: 16) {
                        scheduleItem(icon: "sun.max.fill", text: schedule.meals, color: AppColors.orangeMain)
                        scheduleItem(icon: "cup.and.saucer.fill", text: schedule.snacks, color: AppColors.greenMain)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.infoBlue)
                        Text(schedule.texture)
                            .font(AppFonts.caption())
                            .foregroundColor(AppColors.textMidGray)
                        Spacer()
                    }
                }
                .padding(16)
                .background(AppColors.cardWhite)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.5), value: animateIn)
    }
    
    private func scheduleItem(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
            }
            Text(text)
                .font(AppFonts.caption())
                .foregroundColor(AppColors.textDark)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - CTA Section
    private var ctaSection: some View {
        VStack(spacing: 12) {
            // Primary CTA
            Button(action: {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                onDismiss()
            }) {
                HStack(spacing: 8) {
                    Text("Mulai Perjalanan MPASI 🚀")
                        .font(AppFonts.ctaText())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColors.primaryGradient)
                .cornerRadius(14)
                .shadow(color: AppColors.orangeMain.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            // Secondary text link
            Button(action: {
                onDismiss()
            }) {
                Text("Simpan & Lihat Nanti")
                    .font(AppFonts.bodyRegular())
                    .foregroundColor(AppColors.textMidGray)
            }
        }
        .padding(.top, 8)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.6), value: animateIn)
    }
    
    // MARK: - Reusable Components
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppColors.orangeMain)
            Text(title)
                .font(AppFonts.heading2())
                .foregroundColor(AppColors.textDark)
        }
    }
}


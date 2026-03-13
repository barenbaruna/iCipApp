//
//  RiwayatView.swift
//  iCipApp
//
//  Riwayat Tab — Growth chart & food log history.
//  Apple HIG: segmented control, safe area, animations.
//

import SwiftUI
import SwiftData

// MARK: - Riwayat View
struct RiwayatView: View {
    
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = RiwayatViewModel()
    @State private var selectedSection = 0 // 0 = Grafik, 1 = Riwayat Makanan
    @State private var animateIn = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Segmented Control
                    Picker("", selection: $selectedSection) {
                        Text("Grafik").tag(0)
                        Text("Makanan").tag(1)
                        Text("Pertumbuhan").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    
                    if selectedSection == 0 {
                        growthSection
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else if selectedSection == 1 {
                        FoodLogHistoryView(viewModel: viewModel)
                            .transition(.asymmetric(
                                insertion: .opacity,
                                removal: .opacity
                            ))
                    } else {
                        GrowthHistoryView(viewModel: viewModel)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding(.bottom, 100)
            }
            .background(AppColors.creamWhite.ignoresSafeArea())
//            .navigationTitle("Riwayat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Riwayat")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(AppColors.textDark)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedSection)
            .onAppear {
                viewModel.configure(modelContext: modelContext)
                withAnimation(.easeOut(duration: 0.6).delay(0.2)) { animateIn = true }
            }
            .sheet(isPresented: $viewModel.showInputSheet) {
                InputMeasurementSheet(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
            }
            .sheet(item: $viewModel.selectedFoodLog) { log in
                FoodLogDetailSheet(foodLog: log, viewModel: viewModel)
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    // MARK: - Growth Section
    private var growthSection: some View {
        VStack(spacing: 16) {
            // Status Card
            GrowthStatusCard(status: viewModel.overallStatus)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 15)
            
            // Indicator Tabs
            indicatorTabs
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 15)
            
            // Growth Chart
            GrowthChartView(viewModel: viewModel)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 20)
            
            // Mini Indicator Cards
            ZScoreIndicatorCards(viewModel: viewModel)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 15)
            
            // Warning Cards
            warningCards
            
            // Input Button
            inputButton
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 15)
        }
    }
    
    // MARK: - Indicator Tabs
    private var indicatorTabs: some View {
        HStack(spacing: 8) {
            ForEach(GrowthIndicator.allCases) { indicator in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.selectedIndicator = indicator
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    Text(indicator.rawValue)
                        .font(AppFonts.caption())
                        .fontWeight(viewModel.selectedIndicator == indicator ? .semibold : .regular)
                        .foregroundColor(viewModel.selectedIndicator == indicator ? .white : AppColors.textMidGray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.selectedIndicator == indicator
                                ? AnyShapeStyle(AppColors.primaryGradient)
                                : AnyShapeStyle(AppColors.surfaceGray)
                        )
                        .cornerRadius(20)
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Warning Cards
    private var warningCards: some View {
        VStack(spacing: 12) {
            if viewModel.hasAttentionNeeded {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppColors.warningYellow)
                        .font(.system(size: 18))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Perhatian")
                            .font(AppFonts.heading3())
                            .foregroundColor(AppColors.textDark)
                        Text("Salah satu indikator pertumbuhan si kecil berada di bawah batas normal. Pantau terus dan konsultasikan dengan dokter anak.")
                            .font(AppFonts.caption())
                            .foregroundColor(AppColors.textMidGray)
                            .lineSpacing(3)
                    }
                }
                .padding(16)
                .background(AppColors.warningYellowTint)
                .cornerRadius(16)
                .padding(.horizontal, 24)
            }
            
            if viewModel.hasStuntingRisk {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "fork.knife.circle.fill")
                            .foregroundColor(AppColors.orangeMain)
                            .font(.system(size: 18))
                        Text("Rekomendasi Nutrisi")
                            .font(AppFonts.heading3())
                            .foregroundColor(AppColors.textDark)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(WHOZScoreCalculator.stuntingFoodRecommendations, id: \.nutrient) { rec in
                                VStack(spacing: 6) {
                                    Image(systemName: rec.icon)
                                        .font(.system(size: 20))
                                        .foregroundColor(AppColors.orangeMain)
                                    Text(rec.nutrient)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppColors.textDark)
                                    Text(rec.foods)
                                        .font(.system(size: 10))
                                        .foregroundColor(AppColors.textMidGray)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                                .frame(width: 100)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 8)
                                .background(AppColors.orangeTint)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(16)
                .background(AppColors.cardWhite)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                .padding(.horizontal, 24)
            }
        }
    }
    
    // MARK: - Input Button
    private var inputButton: some View {
        Button(action: {
            viewModel.showInputSheet = true
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                Text("Input Data Pertumbuhan")
                    .font(AppFonts.ctaText())
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppColors.primaryGradient)
            .cornerRadius(14)
        }
        .padding(.horizontal, 24)
    }
}

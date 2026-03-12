//
//  ProfileView.swift
//  iCipApp
//
//  Profile Tab — Baby stats, allergies, growth tracking, reset.
//  Apple HIG: haptic feedback, dark mode, safe area.
//

import SwiftUI
import SwiftData

// MARK: - Profile View
struct ProfileView: View {
    
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ProfileViewModel()
    @State private var animateStats = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                if let baby = viewModel.currentBaby {
                    VStack(spacing: 24) {
                        profileHeader(baby: baby)
                        statsGrid(baby: baby)
                        allergySection(baby: baby)
                        growthSection
                        resetButton
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                } else {
                    emptyState
                }
            }
            .background(AppColors.creamWhite.ignoresSafeArea())
//            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profil")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(AppColors.textDark)
                }
            }
            .alert("Reset Profil?", isPresented: $viewModel.showingResetAlert) {
                Button("Batal", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel.resetProfile()
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                }
            } message: {
                Text("Semua data profil bayi akan dihapus. Tindakan ini tidak bisa dibatalkan.")
            }
            .onAppear {
                viewModel.configure(modelContext: modelContext)
                withAnimation(.easeOut(duration: 0.6).delay(0.2)) { animateStats = true }
            }
        }
    }
    
    // MARK: - Profile Header
    private func profileHeader(baby: Baby) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(AppColors.primaryGradient, lineWidth: 3)
                    .frame(width: 96, height: 96)
                Circle()
                    .fill(AppColors.orangeTint)
                    .frame(width: 86, height: 86)
                Text("👶")
                    .font(.system(size: 44))
            }
            .padding(.top, 12)
            
            VStack(spacing: 4) {
                Text(baby.name)
                    .font(AppFonts.heading1())
                    .foregroundColor(AppColors.textDark)
                
                HStack(spacing: 8) {
                    Label("\(baby.ageInMonths) bulan", systemImage: "calendar")
                    Text("•")
                    Label(baby.gender, systemImage: baby.gender == "Laki-laki" ? "figure.stand" : "figure.stand.dress")
                }
                .font(AppFonts.bodyRegular())
                .foregroundColor(AppColors.textMidGray)
            }
        }
    }
    
    // MARK: - Stats Grid
    private func statsGrid(baby: Baby) -> some View {
        HStack(spacing: 14) {
            if let measurement = viewModel.latestMeasurement {
                profileStatCard(icon: "scalemass.fill", value: String(format: "%.1f", measurement.weightKg), unit: "kg", label: "Berat Badan", color: AppColors.greenMain, bgColor: AppColors.greenTint)
                profileStatCard(icon: "ruler.fill", value: String(format: "%.1f", measurement.heightCm), unit: "cm", label: "Tinggi Badan", color: AppColors.infoBlue, bgColor: Color(light: "#E3F2FD", dark: "#1A2A3D"))
            }
            profileStatCard(icon: "fork.knife", value: "\(viewModel.foodLogCount)", unit: "resep", label: "Sudah Dicoba", color: AppColors.orangeMain, bgColor: AppColors.orangeTint)
        }
        .padding(.horizontal, 24)
        .opacity(animateStats ? 1 : 0)
        .offset(y: animateStats ? 0 : 15)
    }
    
    private func profileStatCard(icon: String, value: String, unit: String, label: String, color: Color, bgColor: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            HStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textDark)
                Text(unit)
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSubtleGray)
            }
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(AppColors.textMidGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(bgColor)
        .cornerRadius(14)
    }
    
    // MARK: - Allergy Section
    private func allergySection(baby: Baby) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "allergens")
                    .foregroundColor(AppColors.alertRed)
                    .font(.system(size: 14))
                Text("Riwayat Alergi")
                    .font(AppFonts.heading3())
                    .foregroundColor(AppColors.textDark)
            }
            
            if baby.allergies.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(AppColors.greenMain)
                    Text("Tidak ada alergi yang tercatat")
                        .font(AppFonts.bodyRegular())
                        .foregroundColor(AppColors.textMidGray)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.greenTint)
                .cornerRadius(12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(baby.allergies, id: \.self) { allergy in
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 10))
                                Text(allergy)
                                    .font(AppFonts.caption())
                            }
                            .foregroundColor(AppColors.alertRed)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(AppColors.alertRedTint)
                            .cornerRadius(20)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Growth Section
    private var growthSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(AppColors.greenMain)
                Text("Grafik Pertumbuhan")
                    .font(AppFonts.heading3())
                    .foregroundColor(AppColors.textDark)
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppColors.surfaceGray)
                    .frame(height: 150)
                
                VStack(spacing: 8) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 30))
                        .foregroundColor(AppColors.textSubtleGray)
                    Text("Grafik Z-Score (Coming Soon)")
                        .font(AppFonts.caption())
                        .foregroundColor(AppColors.textSubtleGray)
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Reset Button
    private var resetButton: some View {
        Button(action: {
            viewModel.showingResetAlert = true
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.counterclockwise")
                Text("Reset Profil Bayi")
                    .font(AppFonts.heading3())
            }
            .foregroundColor(AppColors.alertRed)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppColors.alertRedTint)
            .cornerRadius(12)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "person.crop.circle.badge.questionmark.fill")
                .font(.system(size: 50))
                .foregroundColor(AppColors.textSubtleGray)
            Text("Belum ada profil bayi")
                .font(AppFonts.heading3())
                .foregroundColor(AppColors.textMidGray)
            Spacer()
        }
    }
}

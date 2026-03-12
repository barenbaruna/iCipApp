//
//  FoodDetailView.swift
//  iCipApp
//
//  Recipe detail — Nutrition facts, preparation steps, allergy substitution, food log.
//  Apple HIG: haptic feedback, dark mode adaptive, safe area.
//

import SwiftData
import SwiftUI

// MARK: - Food Detail View
struct FoodDetailView: View {

    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: FoodDetailViewModel
    @State private var animateContent = false

    // MARK: - Initialization
    let recipe: RecipeItem
    let conflicts: [String]

    init(recipe: RecipeItem, conflicts: [String]) {
        self.recipe = recipe
        self.conflicts = conflicts
        _viewModel = StateObject(
            wrappedValue: FoodDetailViewModel(recipe: recipe, conflicts: conflicts))
    }

    // MARK: - Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                heroHeader

                VStack(alignment: .leading, spacing: 24) {
                    titleSection

                    if !conflicts.isEmpty {
                        substitutionWarning
                    }

                    nutritionSection
                    Divider()
                    ingredientsSection
                    Divider()
                    preparationSection

                    Spacer(minLength: 20)
                    ctaButton
                }
                .padding(24)
                .background(AppColors.creamWhite)
                .cornerRadius(24)
                .offset(y: -30)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(AppColors.creamWhite.ignoresSafeArea())
        .onAppear {
            viewModel.configure(modelContext: modelContext)
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) { animateContent = true }
        }
        .sheet(isPresented: $viewModel.showingLogSheet) {
            logReactionSheet
                .presentationDetents([.medium])
                .presentationCornerRadius(24)
        }
    }

    // MARK: - Hero Header
    private var heroHeader: some View {
        GeometryReader { geometry in
            FoodImage(
                imageUrl: recipe.id, ageMinimumMonths: recipe.ageMinimumMonths,
                height: max(geometry.size.width * 0.6, 200)
            )
            .overlay(alignment: .bottom) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 11))
                    Text("Usia \(recipe.ageMinimumMonths)-\(recipe.ageMaximumMonths) Bulan")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.black.opacity(0.45))
                .cornerRadius(20)
                .padding(.bottom, 16)
            }
        }
        .frame(height: 280)
    }

    // MARK: - Title
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.name)
                .font(AppFonts.heading1())
                .foregroundColor(AppColors.textDark)
                .fixedSize(horizontal: false, vertical: true)

            Text("Tekstur: \(recipe.texture)")
                .font(AppFonts.bodyRegular())
                .foregroundColor(AppColors.orangeMain)
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 15)
    }

    // MARK: - Substitution Warning
    private var substitutionWarning: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(AppColors.warningYellow)
                Text("Peringatan Substitusi")
                    .font(AppFonts.heading3())
                    .foregroundColor(AppColors.textDark)
            }

            Text(
                "Resep ini mengandung **\(conflicts.joined(separator: ", "))**. Karena si kecil memiliki alergi, ganti bahan terkait dengan Tahu, Tempe, atau porsi daging yang setara."
            )
            .font(AppFonts.bodyRegular())
            .foregroundColor(AppColors.textMidGray)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(AppColors.warningYellowTint)
        .cornerRadius(14)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    // MARK: - Nutrition Section
    private var nutritionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Kandungan Gizi Per Porsi")
                .font(AppFonts.heading3())
                .foregroundColor(AppColors.textDark)

            HStack(spacing: 12) {
                NutritionBadge(
                    title: "Energi", value: String(format: "%.0f", recipe.calories), unit: "kkal",
                    color: AppColors.orangeMain, bgColor: AppColors.orangeTint)
                NutritionBadge(
                    title: "Protein", value: String(format: "%.1f", recipe.protein), unit: "g",
                    color: AppColors.greenMain, bgColor: AppColors.greenTint)
                NutritionBadge(
                    title: "Lemak", value: String(format: "%.1f", recipe.fat), unit: "g",
                    color: AppColors.infoBlue, bgColor: Color(light: "#E3F2FD", dark: "#1A2A3D"))
            }
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 15)
    }

    // MARK: - Ingredients
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "basket.fill")
                    .foregroundColor(AppColors.greenMain)
                Text("Bahan-bahan")
                    .font(AppFonts.heading3())
                    .foregroundColor(AppColors.textDark)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(recipe.ingredients, id: \.self) { ingredient in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(AppColors.orangeLight)
                            .frame(width: 6, height: 6)
                        Text(ingredient.capitalized)
                            .font(AppFonts.bodyRegular())
                            .foregroundColor(AppColors.textMidGray)
                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: - Preparation
    private var preparationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "list.number")
                    .foregroundColor(AppColors.orangeMain)
                Text("Cara Persiapan")
                    .font(AppFonts.heading3())
                    .foregroundColor(AppColors.textDark)
            }

            ForEach(Array(recipe.preparationSteps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppColors.orangeTint)
                            .frame(width: 28, height: 28)
                        Text("\(index + 1)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.orangeMain)
                    }

                    Text(step)
                        .font(AppFonts.bodyRegular())
                        .foregroundColor(AppColors.textDark)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    // MARK: - CTA Button
    private var ctaButton: some View {
        Button(action: {
            viewModel.showingLogSheet = true
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }) {
            HStack(spacing: 8) {
                Image(systemName: viewModel.isSaved ? "checkmark.circle.fill" : "plus.circle.fill")
                Text(viewModel.isSaved ? "Sudah Dicoba ✓" : "Tandai Sudah Dicoba")
                    .font(AppFonts.ctaText())
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.isSaved ? AppColors.greenGradient : AppColors.primaryGradient)
            .cornerRadius(12)
            .shadow(color: AppColors.greenMain.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(viewModel.isSaved)
        .padding(.bottom, 10)
    }

    // MARK: - Log Reaction Sheet
    private var logReactionSheet: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(AppColors.surfaceGray)
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            Text("Reaksi Si Kecil")
                .font(AppFonts.heading2())
                .foregroundColor(AppColors.textDark)

            HStack(spacing: 12) {
                reactionButton(
                    emoji: "😋", label: "Suka", reaction: "Suka", color: AppColors.greenMain)
                reactionButton(
                    emoji: "😐", label: "Biasa", reaction: "Tidak Suka",
                    color: AppColors.warningYellow)
                reactionButton(
                    emoji: "🤧", label: "Alergi", reaction: "Alergi", color: AppColors.alertRed)
            }
            .padding(.horizontal, 24)

            TextField("Catatan tambahan (opsional)...", text: $viewModel.logNotes)
                .font(AppFonts.bodyRegular())
                .foregroundColor(AppColors.inputText)
                .padding(14)
                .background(AppColors.inputBackground)
                .cornerRadius(12)
                .padding(.horizontal, 24)

            Button(action: {
                viewModel.saveLog()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }) {
                Text("Simpan Log")
                    .font(AppFonts.ctaText())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.primaryGradient)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(AppColors.creamWhite.ignoresSafeArea())
    }

    // MARK: - Helpers
    private func reactionButton(emoji: String, label: String, reaction: String, color: Color)
        -> some View
    {
        Button(action: {
            viewModel.logReaction = reaction
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            VStack(spacing: 6) {
                Text(emoji)
                    .font(.system(size: 32))
                Text(label)
                    .font(AppFonts.caption())
                    .foregroundColor(
                        viewModel.logReaction == reaction ? color : AppColors.textMidGray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                viewModel.logReaction == reaction ? color.opacity(0.1) : AppColors.surfaceGray
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(viewModel.logReaction == reaction ? color : Color.clear, lineWidth: 2)
            )
            .scaleEffect(viewModel.logReaction == reaction ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: viewModel.logReaction)
        }
    }
}

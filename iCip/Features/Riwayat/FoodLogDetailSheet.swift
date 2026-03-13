//
//  FoodLogDetailSheet.swift
//  iCipApp
//
//  Detail sheet for a food log entry — shows full nutritional info.
//

import SwiftUI

// MARK: - Food Log Detail Sheet
struct FoodLogDetailSheet: View {
    
    let foodLog: FoodLog
    @ObservedObject var viewModel: RiwayatViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var recipe: RecipeItem? {
        viewModel.getRecipe(for: foodLog)
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Nutrition info
                    if let recipe = recipe {
                        nutritionSection(recipe: recipe)
                        ingredientsSection(recipe: recipe)
                    } else {
                        noRecipeState
                    }
                    
                    // Log details
                    logDetailsSection
                    
                    Spacer(minLength: 30)
                }
                .padding(.top, 8)
            }
            .background(AppColors.creamWhite.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textSubtleGray)
                            .font(.system(size: 22))
                    }
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.orangeTint)
                    .frame(width: 72, height: 72)
                Image(systemName: "fork.knife")
                    .font(.system(size: 30))
                    .foregroundColor(AppColors.orangeMain)
            }
            
            Text(foodLog.foodName.isEmpty ? "Makanan" : foodLog.foodName)
                .font(AppFonts.heading1())
                .foregroundColor(AppColors.textDark)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Label(MealTypeHelper.normalized(foodLog.mealType), systemImage: "clock.fill")
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.textMidGray)
                
                if foodLog.isAllergyFlagged {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                        Text("Alergi")
                            .font(AppFonts.caption())
                    }
                    .foregroundColor(AppColors.alertRed)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.alertRedTint)
                    .cornerRadius(8)
                }
            }
            
            if !foodLog.nutrientHighlight.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                    Text(foodLog.nutrientHighlight)
                        .font(AppFonts.caption())
                }
                .foregroundColor(AppColors.orangeMain)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.orangeTint)
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Nutrition Section
    private func nutritionSection(recipe: RecipeItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Informasi Nutrisi")
                .font(AppFonts.heading3())
                .foregroundColor(AppColors.textDark)
            
            HStack(spacing: 10) {
                nutritionCard(label: "Kalori", value: "\(Int(recipe.calories))", unit: "kkal", color: AppColors.orangeMain, bgColor: AppColors.orangeTint)
                nutritionCard(label: "Protein", value: String(format: "%.1f", recipe.protein), unit: "g", color: AppColors.greenMain, bgColor: AppColors.greenTint)
                nutritionCard(label: "Lemak", value: String(format: "%.1f", recipe.fat), unit: "g", color: AppColors.infoBlue, bgColor: Color(light: "#E3F2FD", dark: "#1A2A3D"))
            }
        }
        .padding(.horizontal, 24)
    }
    
    private func nutritionCard(label: String, value: String, unit: String, color: Color, bgColor: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(unit)
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSubtleGray)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.textMidGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(bgColor)
        .cornerRadius(14)
    }
    
    // MARK: - Ingredients
    private func ingredientsSection(recipe: RecipeItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Bahan-bahan")
                .font(AppFonts.heading3())
                .foregroundColor(AppColors.textDark)
            
            FlowLayout(spacing: 8) {
                ForEach(recipe.ingredients, id: \.self) { ingredient in
                    Text(ingredient)
                        .font(AppFonts.caption())
                        .foregroundColor(AppColors.textDark)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.surfaceGray)
                        .cornerRadius(20)
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Log Details
    private var logDetailsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Detail Catatan")
                .font(AppFonts.heading3())
                .foregroundColor(AppColors.textDark)
            
            VStack(alignment: .leading, spacing: 8) {
                detailRow(icon: "calendar", label: "Tanggal", value: formattedDate(foodLog.date))
                detailRow(icon: "face.smiling", label: "Reaksi", value: foodLog.reaction)
                
                if !foodLog.notes.isEmpty {
                    detailRow(icon: "note.text", label: "Catatan", value: foodLog.notes)
                }
            }
            .padding(14)
            .background(AppColors.cardWhite)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        }
        .padding(.horizontal, 24)
    }
    
    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppColors.orangeMain)
                .frame(width: 20)
            
            Text(label)
                .font(AppFonts.caption())
                .foregroundColor(AppColors.textMidGray)
                .frame(width: 60, alignment: .leading)
            
            Text(value)
                .font(AppFonts.bodyRegular())
                .foregroundColor(AppColors.textDark)
        }
    }
    
    // MARK: - No Recipe State
    private var noRecipeState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray.fill")
                .font(.system(size: 24))
                .foregroundColor(AppColors.textSubtleGray)
            Text("Detail resep tidak tersedia")
                .font(AppFonts.caption())
                .foregroundColor(AppColors.textMidGray)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(AppColors.surfaceGray)
        .cornerRadius(14)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Helpers
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMMM yyyy, HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Flow Layout (for ingredient chips)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        var rowMaxHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowMaxHeight + spacing
                rowMaxHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowMaxHeight = max(rowMaxHeight, size.height)
            x += size.width + spacing
            maxHeight = max(maxHeight, y + rowMaxHeight)
        }
        
        return (CGSize(width: maxWidth, height: maxHeight), positions)
    }
}

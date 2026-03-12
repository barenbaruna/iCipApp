//
//  HomeViewModel.swift
//  iCip
//
//  Loads baby profile and generates personalized, scored recipe recommendations.
//  Scoring based on WHO Z-Score growth status and Kemenkes nutrition guidelines.
//

import SwiftUI
import SwiftData
import Combine

// MARK: - Recommendation Reason
struct RecommendationReason {
    let tag: String
    let reason: String
    let icon: String
    let isHighlyRecommended: Bool
}

// MARK: - Home ViewModel
@MainActor
class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var recommendedRecipes: [RecipeItem] = []
    @Published var currentBaby: Baby?
    @Published var recipeReasons: [String: RecommendationReason] = [:]
    
    // MARK: - Dependencies
    private let recipeRepo = LocalRecipeRepository.shared
    private var babyRepo: BabyRepositoryProtocol?
    
    // MARK: - Setup
    func setupConfigs(modelContext: ModelContext) {
        self.babyRepo = SwiftDataBabyRepository(context: modelContext)
        loadData()
    }
    
    // MARK: - Actions
    func loadData() {
        do {
            guard let baby = try babyRepo?.getBabies().first else { return }
            self.currentBaby = baby
            let ageInMonths = baby.ageInMonths
            
            let ageAppropriateRecipes = try recipeRepo.getRecipes(forAgeMonths: max(ageInMonths, 6))
            
            // Score and sort recipes based on baby's nutritional needs
            let scoredRecipes = scoreRecipes(ageAppropriateRecipes, for: baby)
            self.recommendedRecipes = scoredRecipes
            generateReasons(for: scoredRecipes, baby: baby)
        } catch {
            print("Failed fetching data: \(error)")
        }
    }
    
    // MARK: - Scoring Engine
    
    /// Scores recipes based on baby's growth status and nutritional needs.
    private func scoreRecipes(_ recipes: [RecipeItem], for baby: Baby) -> [RecipeItem] {
        let status = growthStatusForBaby(baby)
        let allProtein = recipes.map { $0.protein }
        let avgProtein = allProtein.isEmpty ? 4.0 : allProtein.reduce(0, +) / Double(allProtein.count)
        let allCalories = recipes.map { $0.calories }
        let avgCalories = allCalories.isEmpty ? 100.0 : allCalories.reduce(0, +) / Double(allCalories.count)
        let allFat = recipes.map { $0.fat }
        let avgFat = allFat.isEmpty ? 4.0 : allFat.reduce(0, +) / Double(allFat.count)
        
        let scored: [(recipe: RecipeItem, score: Double)] = recipes.map { recipe in
            var score: Double = 0
            let hasConflict = !getConflictingAllergens(for: recipe).isEmpty
            
            switch status {
            case .stuntingRisk:
                // Prioritize high protein and high calorie
                if recipe.protein > avgProtein { score += 30 }
                if recipe.protein > avgProtein * 1.5 { score += 20 }
                if recipe.calories > avgCalories { score += 15 }
                // Bonus for animal protein ingredients
                let animalProteinKeywords = ["ayam", "ikan", "daging", "telur", "udang", "hati"]
                let animalProteinCount = recipe.ingredients.filter { ingredient in
                    animalProteinKeywords.contains(where: { ingredient.lowercased().contains($0) })
                }.count
                score += Double(animalProteinCount) * 10
                
            case .needsAttention:
                // Balanced but lean towards protein
                if recipe.protein > avgProtein { score += 20 }
                if recipe.calories > avgCalories { score += 10 }
                let animalProteinKeywords = ["ayam", "ikan", "daging", "telur", "udang"]
                let animalProteinCount = recipe.ingredients.filter { ingredient in
                    animalProteinKeywords.contains(where: { ingredient.lowercased().contains($0) })
                }.count
                score += Double(animalProteinCount) * 8
                
            case .normal:
                // Balanced variety — favor moderate protein and variety
                if recipe.protein >= avgProtein * 0.8 && recipe.protein <= avgProtein * 1.3 {
                    score += 15 // Well-balanced
                }
                if recipe.calories >= avgCalories * 0.9 && recipe.calories <= avgCalories * 1.2 {
                    score += 10
                }
                // Ingredient variety bonus
                score += Double(min(recipe.ingredients.count, 8)) * 2
                
            case .overweight:
                // Prioritize lower calorie and lower fat
                if recipe.calories < avgCalories { score += 25 }
                if recipe.fat < avgFat { score += 20 }
                // Still need adequate protein
                if recipe.protein >= avgProtein { score += 10 }
                // Prefer vegetable-rich recipes
                let veggieKeywords = ["bayam", "wortel", "brokoli", "labu", "buncis", "sawi", "jagung", "tomat"]
                let veggieCount = recipe.ingredients.filter { ingredient in
                    veggieKeywords.contains(where: { ingredient.lowercased().contains($0) })
                }.count
                score += Double(veggieCount) * 8
                
            case .obese:
                // Strongly prioritize lowest fat and moderate calories
                if recipe.fat < avgFat { score += 30 }
                if recipe.fat < avgFat * 0.7 { score += 15 }
                if recipe.calories < avgCalories { score += 20 }
                // High variety for micronutrients
                score += Double(min(recipe.ingredients.count, 8)) * 3
                // Prefer vegetable-rich recipes
                let veggieKeywords = ["bayam", "wortel", "brokoli", "labu", "buncis", "sawi", "jagung", "tomat"]
                let veggieCount = recipe.ingredients.filter { ingredient in
                    veggieKeywords.contains(where: { ingredient.lowercased().contains($0) })
                }.count
                score += Double(veggieCount) * 10
            }
            
            // Penalize if allergy conflict exists
            if hasConflict { score -= 15 }
            
            return (recipe: recipe, score: score)
        }
        
        return scored.sorted(by: { $0.score > $1.score }).map { $0.recipe }
    }
    
    /// Generates human-readable recommendation reasons for each recipe.
    private func generateReasons(for recipes: [RecipeItem], baby: Baby) {
        let status = growthStatusForBaby(baby)
        var reasons: [String: RecommendationReason] = [:]
        let allProtein = recipes.map { $0.protein }
        let avgProtein = allProtein.isEmpty ? 4.0 : allProtein.reduce(0, +) / Double(allProtein.count)
        let allFat = recipes.map { $0.fat }
        let avgFat = allFat.isEmpty ? 4.0 : allFat.reduce(0, +) / Double(allFat.count)
        let allCalories = recipes.map { $0.calories }
        let avgCalories = allCalories.isEmpty ? 100.0 : allCalories.reduce(0, +) / Double(allCalories.count)
        
        for (index, recipe) in recipes.enumerated() {
            let isTopRecommendation = index < 3
            
            let reason: RecommendationReason
            switch status {
            case .stuntingRisk:
                if recipe.protein > avgProtein * 1.3 {
                    reason = RecommendationReason(
                        tag: "Tinggi Protein",
                        reason: "Kandungan protein \(String(format: "%.1f", recipe.protein))g membantu mengejar pertumbuhan berat badan optimal",
                        icon: "bolt.heart.fill",
                        isHighlyRecommended: isTopRecommendation
                    )
                } else if recipe.calories > 120 {
                    reason = RecommendationReason(
                        tag: "Padat Energi",
                        reason: "Energi \(Int(recipe.calories)) kkal mendukung kebutuhan kalori harian untuk tumbuh kembang",
                        icon: "flame.fill",
                        isHighlyRecommended: isTopRecommendation
                    )
                } else {
                    reason = RecommendationReason(
                        tag: "Bergizi Seimbang",
                        reason: "Kombinasi nutrisi seimbang untuk mendukung pertumbuhan",
                        icon: "leaf.fill",
                        isHighlyRecommended: false
                    )
                }
                
            case .needsAttention:
                if recipe.protein > avgProtein {
                    reason = RecommendationReason(
                        tag: "Protein Ekstra",
                        reason: "Protein \(String(format: "%.1f", recipe.protein))g untuk perbaikan status gizi si kecil",
                        icon: "arrow.up.heart.fill",
                        isHighlyRecommended: isTopRecommendation
                    )
                } else {
                    reason = RecommendationReason(
                        tag: "Gizi Seimbang",
                        reason: "Komposisi gizi seimbang sesuai kebutuhan usia \(baby.ageInMonths) bulan",
                        icon: "leaf.fill",
                        isHighlyRecommended: isTopRecommendation && index < 2
                    )
                }
                
            case .normal:
                if recipe.ingredients.count >= 6 {
                    reason = RecommendationReason(
                        tag: "Variasi Lengkap",
                        reason: "Beragam bahan makanan untuk memenuhi kebutuhan nutrisi harian",
                        icon: "sparkles",
                        isHighlyRecommended: isTopRecommendation && index == 0
                    )
                } else if recipe.protein > avgProtein {
                    reason = RecommendationReason(
                        tag: "Kaya Protein",
                        reason: "Protein \(String(format: "%.1f", recipe.protein))g untuk pertumbuhan optimal",
                        icon: "star.fill",
                        isHighlyRecommended: isTopRecommendation && index == 0
                    )
                } else {
                    reason = RecommendationReason(
                        tag: "Sesuai Usia",
                        reason: "Tekstur dan nutrisi tepat untuk usia \(baby.ageInMonths) bulan",
                        icon: "checkmark.seal.fill",
                        isHighlyRecommended: false
                    )
                }
                
            case .overweight:
                if recipe.fat < avgFat {
                    reason = RecommendationReason(
                        tag: "Rendah Lemak",
                        reason: "Lemak \(String(format: "%.1f", recipe.fat))g — pilihan tepat untuk menjaga berat badan ideal si kecil",
                        icon: "heart.circle.fill",
                        isHighlyRecommended: isTopRecommendation
                    )
                } else {
                    reason = RecommendationReason(
                        tag: "Seimbang",
                        reason: "Porsi kalori terkontrol sesuai kebutuhan usia \(baby.ageInMonths) bulan",
                        icon: "scale.3d",
                        isHighlyRecommended: false
                    )
                }
                
            case .obese:
                if recipe.fat < avgFat && recipe.calories < avgCalories {
                    reason = RecommendationReason(
                        tag: "Rendah Lemak & Kalori",
                        reason: "Lemak \(String(format: "%.1f", recipe.fat))g dan energi \(Int(recipe.calories)) kkal — mendukung penurunan berat badan ke zona aman",
                        icon: "arrow.down.heart.fill",
                        isHighlyRecommended: isTopRecommendation
                    )
                } else {
                    reason = RecommendationReason(
                        tag: "Porsi Terkontrol",
                        reason: "Komposisi nutrisi disesuaikan untuk mengelola berat badan",
                        icon: "scale.3d",
                        isHighlyRecommended: false
                    )
                }
            }
            
            reasons[recipe.id] = reason
        }
        
        self.recipeReasons = reasons
    }
    
    /// Calculates growth status for a baby using latest measurement.
    private func growthStatusForBaby(_ baby: Baby) -> GrowthStatus {
        guard let m = baby.measurements.sorted(by: { $0.date < $1.date }).last else {
            return .normal
        }
        let isMale = baby.gender == "Laki-laki"
        let wfaZ = WHOZScoreCalculator.weightForAgeZ(weightKg: m.weightKg, ageMonths: baby.ageInMonths, isMale: isMale)
        let hfaZ = WHOZScoreCalculator.heightForAgeZ(heightCm: m.heightCm, ageMonths: baby.ageInMonths, isMale: isMale)
        let wfhZ = WHOZScoreCalculator.weightForHeightZ(weightKg: m.weightKg, heightCm: m.heightCm, isMale: isMale)
        return WHOZScoreCalculator.overallStatus(wfaZ: wfaZ, hfaZ: hfaZ, wfhZ: wfhZ)
    }
    
    // MARK: - Helpers
    
    /// Returns allergens present in both the recipe and baby's allergy list.
    func getConflictingAllergens(for recipe: RecipeItem) -> [String] {
        guard let baby = currentBaby else { return [] }
        return recipe.allergens.filter { baby.allergies.contains($0) }
    }
    
    /// Returns the recommendation reason for a recipe.
    func reason(for recipe: RecipeItem) -> RecommendationReason? {
        recipeReasons[recipe.id]
    }
    
    // MARK: - Growth Status (Z-Score)
    
    /// Overall growth status from the latest measurement's Z-scores.
    var overallGrowthStatus: GrowthStatus {
        guard let baby = currentBaby else { return .normal }
        return growthStatusForBaby(baby)
    }
    
    /// Whether baby has at least one growth measurement.
    var hasMeasurementData: Bool {
        currentBaby?.measurements.isEmpty == false
    }
    
    // MARK: - Nutrition Ratio (Kemenkes)
    
    /// ASI percentage based on baby's age group (Kemenkes guideline).
    var nutrisiASI: Double {
        guard let age = currentBaby?.ageInMonths else { return 0.7 }
        if age <= 8 { return 0.7 }
        else if age <= 11 { return 0.5 }
        else { return 0.3 }
    }
    
    /// MPASI percentage based on baby's age group (Kemenkes guideline).
    var nutrisiMPASI: Double {
        1.0 - nutrisiASI
    }
    
    /// Age group label for the nutrition chart.
    var nutrisiAgeGroup: String {
        guard let age = currentBaby?.ageInMonths else { return "6-8 bulan" }
        if age <= 8 { return "6-8 bulan" }
        else if age <= 11 { return "9-11 bulan" }
        else { return "12-24 bulan" }
    }
}

//
//  OnboardingResultViewModel.swift
//  iCipApp
//
//  ViewModel for the celebratory result sheet after onboarding.
//  Calculates Z-scores, nutrition targets, food recommendations.
//

import SwiftUI
import SwiftData
import Combine

// MARK: - Nutrient Target
struct NutrientTarget: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let value: String
    var isCritical: Bool = false
}

// MARK: - Feeding Schedule Info
struct FeedingScheduleInfo: Identifiable {
    let id = UUID()
    let ageRange: String
    let meals: String
    let snacks: String
    let texture: String
}

// MARK: - Food Recommendation
struct FoodRecommendation: Identifiable {
    let id = UUID()
    let name: String
    let benefitTag: String
    let ageBadge: String
    let recipeItem: RecipeItem?
}

// MARK: - Onboarding Result ViewModel
@MainActor
class OnboardingResultViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var baby: Baby
    @Published var showRecipeDetail = false
    @Published var selectedRecipe: RecipeItem?

    var ageInMonths: Int {
        baby.ageInMonths
    }

    var isComplementaryFeedingAge: Bool {
        ageInMonths >= 6 && ageInMonths <= 23
    }
    
    // MARK: - Computed: Z-Scores
    var isMale: Bool { baby.gender == "Laki-laki" }

    var latestMeasurement: GrowthMeasurement? {
        baby.measurements.sorted(by: { $0.date < $1.date }).last
    }
    
    var weightForAgeZ: Double? {
        guard let m = latestMeasurement else { return nil }
        let measurementAgeMonths = baby.ageInMonths(at: m.date)
        return WHOZScoreCalculator.weightForAgeZ(weightKg: m.weightKg, ageMonths: measurementAgeMonths, isMale: isMale)
    }
    
    var heightForAgeZ: Double? {
        guard let m = latestMeasurement else { return nil }
        let measurementAgeMonths = baby.ageInMonths(at: m.date)
        return WHOZScoreCalculator.heightForAgeZ(heightCm: m.heightCm, ageMonths: measurementAgeMonths, isMale: isMale)
    }
    
    var weightForHeightZ: Double? {
        guard let m = latestMeasurement else { return nil }
        return WHOZScoreCalculator.weightForHeightZ(weightKg: m.weightKg, heightCm: m.heightCm, isMale: isMale)
    }
    
    // MARK: - Z-Score for indicator
    func zScore(for indicator: GrowthIndicator) -> Double? {
        switch indicator {
        case .weightForAge: return weightForAgeZ
        case .heightForAge: return heightForAgeZ
        case .weightForHeight: return weightForHeightZ
        }
    }
    
    // MARK: - Overall Status
    var overallStatus: GrowthStatus {
        WHOZScoreCalculator.overallStatus(wfaZ: weightForAgeZ, hfaZ: heightForAgeZ, wfhZ: weightForHeightZ)
    }
    
    var worstZScore: Double {
        [weightForAgeZ, heightForAgeZ, weightForHeightZ].compactMap { $0 }.min() ?? 0
    }
    
    // MARK: - Contextual Message
    var contextualMessage: String {
        switch overallStatus {
        case .stuntingRisk:
            return "Kami mendeteksi risiko stunting. Jangan khawatir — app ini akan membantumu setiap hari 💪"
        case .needsAttention:
            return "Pertumbuhan si kecil perlu perhatian lebih. Yuk tingkatkan asupan gizinya!"
        case .normal:
            return "Si kecil tumbuh dengan baik! Pertahankan pola makan bergizi seimbang ya, Bunda 🎉"
        case .overweight:
            return "Pertumbuhan si kecil di atas rata-rata! Pastikan keseimbangan nutrisinya terjaga ya 🌟"
        case .obese:
            return "Berat badan si kecil cukup tinggi. Yuk perhatikan porsi dan variasi makanannya 🍎"
        }
    }
    
    // MARK: - Nutrition Targets
    var nutrientTargets: [NutrientTarget] {
        let age = ageInMonths
        var targets: [NutrientTarget]

        if age < 6 {
            return [
                NutrientTarget(name: "ASI/Formula", icon: "drop.fill", value: "Utama sesuai kebutuhan"),
                NutrientTarget(name: "Makanan Padat", icon: "fork.knife", value: "Belum direkomendasikan"),
                NutrientTarget(name: "Kesiapan MPASI", icon: "calendar", value: "Mulai sekitar 6 bulan"),
            ]
        }

        if age > 23 {
            return [
                NutrientTarget(name: "Cakupan Onboarding", icon: "info.circle", value: "Dirancang untuk usia 6-23 bulan"),
                NutrientTarget(name: "Status Saat Ini", icon: "calendar", value: "Usia di atas rentang onboarding"),
                NutrientTarget(name: "Lanjutan", icon: "house.fill", value: "Gunakan rekomendasi di Beranda"),
            ]
        }
        
        if age <= 8 {
            targets = [
                NutrientTarget(name: "Total Kalori MPASI", icon: "flame.fill", value: "~200 kkal"),
                NutrientTarget(name: "Protein", icon: "fish.fill", value: "9–11 g"),
                NutrientTarget(name: "Zat Besi", icon: "leaf.fill", value: "11 mg"),
                NutrientTarget(name: "Zinc", icon: "bolt.fill", value: "3 mg"),
                NutrientTarget(name: "Kalsium", icon: "cup.and.saucer.fill", value: "270 mg"),
                NutrientTarget(name: "Vitamin A", icon: "eye.fill", value: "400 mcg"),
            ]
        } else if age <= 11 {
            targets = [
                NutrientTarget(name: "Total Kalori MPASI", icon: "flame.fill", value: "~300 kkal"),
                NutrientTarget(name: "Protein", icon: "fish.fill", value: "12–14 g"),
                NutrientTarget(name: "Zat Besi", icon: "leaf.fill", value: "11 mg"),
                NutrientTarget(name: "Zinc", icon: "bolt.fill", value: "4 mg"),
                NutrientTarget(name: "Kalsium", icon: "cup.and.saucer.fill", value: "270 mg"),
                NutrientTarget(name: "Vitamin A", icon: "eye.fill", value: "400 mcg"),
            ]
        } else {
            targets = [
                NutrientTarget(name: "Total Kalori MPASI", icon: "flame.fill", value: "~700 kkal"),
                NutrientTarget(name: "Protein", icon: "fish.fill", value: "15–20 g"),
                NutrientTarget(name: "Zat Besi", icon: "leaf.fill", value: "7 mg"),
                NutrientTarget(name: "Zinc", icon: "bolt.fill", value: "5 mg"),
                NutrientTarget(name: "Kalsium", icon: "cup.and.saucer.fill", value: "500 mg"),
                NutrientTarget(name: "Vitamin A", icon: "eye.fill", value: "400 mcg"),
            ]
        }
        
        // Highlight critical nutrients based on Z-scores
        if let hfaZ = heightForAgeZ, hfaZ < -1 {
            for i in targets.indices {
                if targets[i].name == "Zinc" || targets[i].name == "Kalsium" {
                    targets[i].isCritical = true
                }
            }
        }
        if let wfaZ = weightForAgeZ, wfaZ < -1 {
            for i in targets.indices {
                if targets[i].name.contains("Kalori") || targets[i].name == "Protein" {
                    targets[i].isCritical = true
                }
            }
        }
        
        return targets
    }
    
    // MARK: - Food Recommendations
    var foodRecommendations: [FoodRecommendation] {
        let age = ageInMonths

        guard isComplementaryFeedingAge else {
            return []
        }

        guard let recipes = try? LocalRecipeRepository.shared.getRecipes(forAgeMonths: age) else {
            return []
        }

        let safeRecipes = recipes.filter { recipe in
            Set(recipe.allergens).isDisjoint(with: Set(baby.allergies))
        }
        
        // Sort by nutritional priority based on Z-scores
        let sorted = safeRecipes.sorted { a, b in
            priorityScore(for: a) > priorityScore(for: b)
        }
        
        let selected = Array(sorted.prefix(6))
        
        return selected.map { recipe in
            let benefit = benefitTag(for: recipe)
            let ageBadge = "\(recipe.ageMinimumMonths) bln+"
            return FoodRecommendation(
                name: recipe.name,
                benefitTag: benefit,
                ageBadge: ageBadge,
                recipeItem: recipe
            )
        }
    }

    var foodRecommendationNotice: String {
        if ageInMonths < 6 {
            return "Si kecil masih di bawah 6 bulan. Fokus pada ASI/formula dulu, MPASI mulai sekitar usia 6 bulan."
        }

        if ageInMonths > 23 {
            return "Onboarding Result dirancang untuk usia 6-23 bulan. Rekomendasi lanjutan tersedia di beranda."
        }

        if foodRecommendations.isEmpty {
            if !baby.allergies.isEmpty {
                return "Belum ada menu awal yang aman setelah filter alergi. Silakan cek alergi profil atau gunakan menu alternatif di beranda."
            }
            return "Belum ada rekomendasi menu untuk profil ini. Coba perbarui data profil dan pengukuran."
        }

        return ""
    }
    
    private func priorityScore(for recipe: RecipeItem) -> Double {
        var score: Double = 0
        
        // BB/U < -1 → prioritize high-calorie, high-protein
        if let wfaZ = weightForAgeZ, wfaZ < -1 {
            score += recipe.calories / 100.0
            score += recipe.protein / 5.0
        }
        
        // TB/U < -1 → prioritize zinc & calcium rich (approximate by protein content)
        if let hfaZ = heightForAgeZ, hfaZ < -1 {
            score += recipe.protein / 5.0
            // Bonus for ingredients associated with zinc/calcium
            let zincFoods = ["ikan", "tahu", "brokoli", "susu", "keju", "daging"]
            for ingredient in recipe.ingredients {
                if zincFoods.contains(where: { ingredient.lowercased().contains($0) }) {
                    score += 1.0
                }
            }
        }
        
        // BB/U > +2 → prioritize lower-calorie nutrient-dense
        if let wfaZ = weightForAgeZ, wfaZ > 2 {
            score += max(0, 200 - recipe.calories) / 100.0
            score += recipe.protein / 10.0
        }
        
        // Default balanced score
        score += recipe.protein / 10.0
        score += min(recipe.calories, 150) / 100.0
        
        return score
    }
    
    private func benefitTag(for recipe: RecipeItem) -> String {
        var tags: [String] = []
        if recipe.protein >= 5 { tags.append("Protein") }
        if recipe.calories >= 100 { tags.append("Energi") }
        if recipe.fat >= 4 { tags.append("Lemak Sehat") }
        
        // Check ingredient-based benefits
        let ironFoods = ["hati", "bayam", "daging"]
        let calciumFoods = ["susu", "keju", "brokoli", "tahu"]
        
        for ingredient in recipe.ingredients {
            let lower = ingredient.lowercased()
            if ironFoods.contains(where: { lower.contains($0) }) && !tags.contains("Zat Besi") {
                tags.append("Zat Besi")
            }
            if calciumFoods.contains(where: { lower.contains($0) }) && !tags.contains("Kalsium") {
                tags.append("Kalsium")
            }
        }
        
        let selected = Array(tags.prefix(2))
        return selected.isEmpty ? "Gizi Seimbang" : "Tinggi \(selected.joined(separator: " & "))"
    }
    
    // MARK: - Feeding Schedule
    var feedingSchedules: [FeedingScheduleInfo] {
        let age = ageInMonths

        if age < 6 {
            return [FeedingScheduleInfo(
                ageRange: "0-5 bulan",
                meals: "ASI/formula sesuai kebutuhan",
                snacks: "Belum perlu MPASI",
                texture: "Belum perlu makanan padat sampai sekitar 6 bulan"
            )]
        }

        if age > 23 {
            return [FeedingScheduleInfo(
                ageRange: "24+ bulan",
                meals: "Di luar cakupan onboarding",
                snacks: "Lihat rekomendasi lanjutan",
                texture: "Gunakan panduan personal di beranda"
            )]
        }
        
        if age <= 8 {
            return [FeedingScheduleInfo(
                ageRange: "6–8 bulan",
                meals: "2–3× makan utama",
                snacks: "1–2× selingan",
                texture: "Tekstur bubur halus"
            )]
        } else if age <= 11 {
            return [FeedingScheduleInfo(
                ageRange: "9–11 bulan",
                meals: "3–4× makan utama",
                snacks: "1–2× selingan",
                texture: "Tekstur cincang halus"
            )]
        } else {
            return [FeedingScheduleInfo(
                ageRange: "12–23 bulan",
                meals: "3× makan utama",
                snacks: "2× selingan",
                texture: "Tekstur makanan keluarga"
            )]
        }
    }
    
    // MARK: - Init
    init(baby: Baby) {
        self.baby = baby
    }
    
    // MARK: - Actions
    func markAsSeen() {
        baby.hasSeenInitialAnalysis = true
    }
}

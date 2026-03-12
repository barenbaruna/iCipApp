//
//  OnboardingResultViewModel.swift
//  iCipApp
//
//  Computes Z-scores, nutritional targets, and food recommendations
//  for the celebratory result sheet shown after onboarding.
//

import SwiftUI
import SwiftData

// MARK: - Baby Profile Data (plain struct, no SwiftData)
struct BabyProfileData {
    let name: String
    let dateOfBirth: Date
    let gender: String
    let allergies: [String]
    let weightKg: Double
    let heightCm: Double
    
    var isMale: Bool { gender == "Laki-laki" }
    
    var ageInMonths: Int {
        let components = Calendar.current.dateComponents([.month], from: dateOfBirth, to: Date())
        return components.month ?? 0
    }
}

// MARK: - Nutrient Target
struct NutrientTarget: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let value: String
    var isHighlighted: Bool = false
}

// MARK: - Feeding Schedule
struct FeedingSchedule: Identifiable {
    let id = UUID()
    let ageRange: String
    let mealCount: String
    let snackCount: String
    let texture: String
    let icon: String
}

// MARK: - Onboarding Result ViewModel
class OnboardingResultViewModel {
    
    // MARK: - Properties
    let profileData: BabyProfileData
    
    // MARK: - Z-Scores
    let weightForAgeZ: Double?
    let heightForAgeZ: Double?
    let weightForHeightZ: Double?
    
    // MARK: - Computed
    var overallStatus: GrowthStatus {
        WHOZScoreCalculator.overallStatus(wfaZ: weightForAgeZ, hfaZ: heightForAgeZ, wfhZ: weightForHeightZ)
    }
    
    var contextualMessage: String {
        switch overallStatus {
        case .normal:
            return "Si kecil tumbuh dengan baik! Pertahankan pola makan bergizi seimbang ya, Bunda 🎉"
        case .needsAttention:
            return "Ada indikator yang perlu perhatian lebih. Yuk tingkatkan asupan nutrisi si kecil! 💛"
        case .stuntingRisk:
            return "Kami mendeteksi risiko stunting. Jangan khawatir — app ini akan membantumu setiap hari 💪"
        }
    }
    
    // MARK: - Food Recommendations
    var recommendedRecipes: [RecipeItem] {
        let allRecipes = (try? LocalRecipeRepository.shared.getRecipes(forAgeMonths: profileData.ageInMonths)) ?? []
        
        let sorted = allRecipes.sorted { a, b in
            if (weightForAgeZ ?? 0) < -1 {
                return a.calories > b.calories
            }
            if (heightForAgeZ ?? 0) < -1 {
                return a.protein > b.protein
            }
            return false
        }
        
        return Array(sorted.prefix(6))
    }
    
    func benefitTag(for recipe: RecipeItem) -> String {
        if recipe.protein >= 5 && recipe.calories >= 100 {
            return "Tinggi Protein & Energi"
        } else if recipe.protein >= 5 {
            return "Tinggi Protein"
        } else if recipe.calories >= 100 {
            return "Tinggi Energi"
        } else {
            return "Bergizi Seimbang"
        }
    }
    
    func ageBadge(for recipe: RecipeItem) -> String {
        "\(recipe.ageMinimumMonths) bln+"
    }
    
    // MARK: - Nutrient Targets
    var nutrientTargets: [NutrientTarget] {
        let wfaLow = (weightForAgeZ ?? 0) < -1
        let hfaLow = (heightForAgeZ ?? 0) < -1
        
        switch profileData.ageInMonths {
        case 6...8:
            return [
                NutrientTarget(name: "Kalori MPASI", icon: "flame.fill", value: "~200 kkal", isHighlighted: wfaLow),
                NutrientTarget(name: "Protein", icon: "fish.fill", value: "9–11 g", isHighlighted: wfaLow),
                NutrientTarget(name: "Zat Besi", icon: "leaf.fill", value: "11 mg"),
                NutrientTarget(name: "Zinc", icon: "bolt.fill", value: "3 mg", isHighlighted: hfaLow),
                NutrientTarget(name: "Kalsium", icon: "cup.and.saucer.fill", value: "270 mg", isHighlighted: hfaLow),
                NutrientTarget(name: "Vitamin A", icon: "eye.fill", value: "400 mcg"),
            ]
        case 9...11:
            return [
                NutrientTarget(name: "Kalori MPASI", icon: "flame.fill", value: "~300 kkal", isHighlighted: wfaLow),
                NutrientTarget(name: "Protein", icon: "fish.fill", value: "12–14 g", isHighlighted: wfaLow),
                NutrientTarget(name: "Zat Besi", icon: "leaf.fill", value: "11 mg"),
                NutrientTarget(name: "Zinc", icon: "bolt.fill", value: "4 mg", isHighlighted: hfaLow),
                NutrientTarget(name: "Kalsium", icon: "cup.and.saucer.fill", value: "270 mg", isHighlighted: hfaLow),
                NutrientTarget(name: "Vitamin A", icon: "eye.fill", value: "400 mcg"),
            ]
        default:
            return [
                NutrientTarget(name: "Kalori MPASI", icon: "flame.fill", value: "~700 kkal", isHighlighted: wfaLow),
                NutrientTarget(name: "Protein", icon: "fish.fill", value: "15–20 g", isHighlighted: wfaLow),
                NutrientTarget(name: "Zat Besi", icon: "leaf.fill", value: "7 mg"),
                NutrientTarget(name: "Zinc", icon: "bolt.fill", value: "5 mg", isHighlighted: hfaLow),
                NutrientTarget(name: "Kalsium", icon: "cup.and.saucer.fill", value: "500 mg", isHighlighted: hfaLow),
                NutrientTarget(name: "Vitamin A", icon: "eye.fill", value: "400 mcg"),
            ]
        }
    }
    
    // MARK: - Feeding Schedule
    var feedingSchedules: [FeedingSchedule] {
        [
            FeedingSchedule(ageRange: "6–8 bln", mealCount: "2–3x", snackCount: "1–2x selingan", texture: "Bubur halus", icon: "drop.fill"),
            FeedingSchedule(ageRange: "9–11 bln", mealCount: "3–4x", snackCount: "1–2x selingan", texture: "Cincang halus", icon: "square.grid.2x2.fill"),
            FeedingSchedule(ageRange: "12–23 bln", mealCount: "3x", snackCount: "2x selingan", texture: "Makanan keluarga", icon: "fork.knife"),
        ]
    }
    
    var currentFeedingIndex: Int {
        switch profileData.ageInMonths {
        case 6...8: return 0
        case 9...11: return 1
        default: return 2
        }
    }
    
    // MARK: - Initialization
    init(profileData: BabyProfileData) {
        self.profileData = profileData
        
        self.weightForAgeZ = WHOZScoreCalculator.weightForAgeZ(
            weightKg: profileData.weightKg, ageMonths: profileData.ageInMonths, isMale: profileData.isMale
        )
        self.heightForAgeZ = WHOZScoreCalculator.heightForAgeZ(
            heightCm: profileData.heightCm, ageMonths: profileData.ageInMonths, isMale: profileData.isMale
        )
        self.weightForHeightZ = WHOZScoreCalculator.weightForHeightZ(
            weightKg: profileData.weightKg, heightCm: profileData.heightCm, isMale: profileData.isMale
        )
    }
}

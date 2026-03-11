//
//  HomeViewModel.swift
//  iCipApp
//
//  Loads baby profile and generates age-appropriate recipe recommendations.
//

import SwiftUI
import SwiftData
import Combine

// MARK: - Home ViewModel
@MainActor
class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var recommendedRecipes: [RecipeItem] = []
    @Published var currentBaby: Baby?
    
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
            
            // Filter recipes by age. Minimum 6 months as safety fallback.
            let ageAppropriateRecipes = try recipeRepo.getRecipes(forAgeMonths: max(ageInMonths, 6))
            
            // PRD: Flag allergens, don't exclude. Shuffle for variety.
            self.recommendedRecipes = ageAppropriateRecipes.shuffled()
        } catch {
            print("Failed fetching data: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    /// Returns allergens present in both the recipe and baby's allergy list.
    func getConflictingAllergens(for recipe: RecipeItem) -> [String] {
        guard let baby = currentBaby else { return [] }
        return recipe.allergens.filter { baby.allergies.contains($0) }
    }
}

//
//  FoodListViewModel.swift
//  iCipApp
//
//  Manages recipe listing, search, and age-based filtering.
//

import SwiftUI
import Combine

// MARK: - Food List ViewModel
@MainActor
class FoodListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var searchText: String = ""
    @Published var selectedAgeFilter: String = "Semua"
    @Published var allRecipes: [RecipeItem] = []
    
    // MARK: - Constants
    let ageFilters = ["Semua", "6-8 bln", "9-11 bln", "12-23 bln"]
    
    // MARK: - Dependencies
    private let recipeRepo = LocalRecipeRepository.shared
    
    // MARK: - Computed Properties
    
    /// Filters recipes by search text and age range using overlap logic.
    var filteredRecipes: [RecipeItem] {
        var result = allRecipes
        
        // Search filter
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Age filter — uses OVERLAP logic (not fit-within)
        switch selectedAgeFilter {
        case "6-8 bln":
            result = result.filter { $0.ageMinimumMonths <= 8 && $0.ageMaximumMonths >= 6 }
        case "9-11 bln":
            result = result.filter { $0.ageMinimumMonths <= 11 && $0.ageMaximumMonths >= 9 }
        case "12-23 bln":
            result = result.filter { $0.ageMinimumMonths <= 24 && $0.ageMaximumMonths >= 12 }
        default:
            break
        }
        
        return result
    }
    
    // MARK: - Actions
    func loadRecipes() {
        guard allRecipes.isEmpty else { return }
        do {
            allRecipes = try recipeRepo.getAllRecipes()
        } catch {
            print("Failed to load recipes: \(error)")
        }
    }
    
    func clearSearch() {
        searchText = ""
    }
}

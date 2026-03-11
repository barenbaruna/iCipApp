//
//  LocalRecipeRepository.swift
//  iCipApp
//
//  Loads and caches Kemenkes recipes from the bundled foods.json.
//  Uses a shared singleton to avoid redundant JSON parsing.
//

import Foundation

// MARK: - Local Recipe Repository (Singleton)
final class LocalRecipeRepository: RecipeRepositoryProtocol {
    
    // MARK: - Singleton
    static let shared = LocalRecipeRepository()
    
    // MARK: - Properties
    private var cachedRecipes: [RecipeItem] = []
    
    // MARK: - Initialization
    private init() {
        loadJSON()
    }
    
    // MARK: - Private Methods
    private func loadJSON() {
        guard let url = Bundle.main.url(forResource: "foods", withExtension: "json") else {
            print("ERROR: Could not find foods.json in bundle.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            cachedRecipes = try decoder.decode([RecipeItem].self, from: data)
        } catch {
            print("ERROR parsing foods.json: \(error)")
        }
    }
    
    // MARK: - Protocol Conformance
    func getAllRecipes() throws -> [RecipeItem] {
        return cachedRecipes
    }
    
    func getRecipes(forAgeMonths age: Int) throws -> [RecipeItem] {
        return cachedRecipes.filter { recipe in
            age >= recipe.ageMinimumMonths && age <= recipe.ageMaximumMonths
        }
    }
}

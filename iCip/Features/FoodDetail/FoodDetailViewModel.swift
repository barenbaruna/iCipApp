//
//  FoodDetailViewModel.swift
//  iCipApp
//
//  Manages food log saving and allergen conflict checks for a recipe.
//

import SwiftUI
import SwiftData
import Combine

// MARK: - Food Detail ViewModel
@MainActor
class FoodDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var logReaction: String = "Suka"
    @Published var logNotes: String = ""
    @Published var showingLogSheet: Bool = false
    @Published var isSaved: Bool = false
    
    // MARK: - Properties
    let recipe: RecipeItem
    let conflicts: [String]
    
    // MARK: - Dependencies
    private var logRepo: FoodLogRepositoryProtocol?
    private var babyRepo: BabyRepositoryProtocol?
    
    // MARK: - Initialization
    init(recipe: RecipeItem, conflicts: [String]) {
        self.recipe = recipe
        self.conflicts = conflicts
    }
    
    // MARK: - Setup
    func configure(modelContext: ModelContext) {
        self.logRepo = SwiftDataLogRepository(context: modelContext)
        self.babyRepo = SwiftDataBabyRepository(context: modelContext)
        
        do {
            if let baby = try babyRepo?.getBabies().first,
               let logs = try logRepo?.getLogs(for: baby.id) {
                if logs.contains(where: { $0.recipeId == recipe.id }) {
                    isSaved = true
                }
            }
        } catch {
            print("Failed to check logs: \(error)")
        }
    }
    
    // MARK: - Actions
    
    /// Saves a food reaction log for the current baby.
    func saveLog() {
        do {
            guard let baby = try babyRepo?.getBabies().first else { return }
            let newLog = FoodLog(recipeId: recipe.id, reaction: logReaction, notes: logNotes)
            try logRepo?.addLog(newLog, to: baby.id)
            isSaved = true
            showingLogSheet = false
        } catch {
            print("Failed to save log: \(error)")
        }
    }
}

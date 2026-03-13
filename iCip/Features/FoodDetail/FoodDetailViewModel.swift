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
    @Published var selectedMealType: String = MealTypeHelper.inferredMealType(from: Date())
    @Published var showingLogSheet: Bool = false
    @Published var isSaved: Bool = false
    @Published var latestReaction: String?
    
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
        selectedMealType = MealTypeHelper.inferredMealType(from: Date())
        refreshLogState()
    }

    private func refreshLogState() {
        
        do {
            if let baby = try babyRepo?.getBabies().first,
               let logs = try logRepo?.getLogs(for: baby.id) {
                let matchingLogs = logs.filter { $0.recipeId == recipe.id }
                isSaved = !matchingLogs.isEmpty
                latestReaction = matchingLogs.sorted(by: { $0.date > $1.date }).first?.reaction
            }
        } catch {
            print("Failed to check logs: \(error)")
        }
    }

    var actionButtonTitle: String {
        if shouldSuggestRetry {
            return "Coba Lagi Menu Ini"
        }
        if isSaved {
            return "Sudah Dicoba - Catat Lagi"
        }
        return "Tandai Sudah Dicoba"
    }

    var shouldSuggestRetry: Bool {
        guard latestReaction == "Tidak Suka" else { return false }
        return true
    }

    var isAllergyRecipe: Bool {
        !conflicts.isEmpty || latestReaction == "Alergi"
    }

    var retryGuidanceText: String {
        if latestReaction == "Alergi" {
            return "Ada riwayat alergi pada menu ini. Hentikan pemberian dan konsultasikan ke tenaga kesehatan sebelum mencoba kembali."
        }
        if shouldSuggestRetry {
            return "Respon biasa/tidak suka masih bisa terjadi pada paparan awal. Ulangi porsi kecil setelah 2-3 hari, hingga 8-10 kali paparan secara bertahap."
        }
        return ""
    }
    
    // MARK: - Actions
    
    /// Saves a food reaction log for the current baby.
    func saveLog() {
        do {
            guard let baby = try babyRepo?.getBabies().first else { return }
            let newLog = FoodLog(
                recipeId: recipe.id,
                reaction: logReaction,
                notes: logNotes,
                date: Date(),
                mealType: selectedMealType,
                foodName: recipe.name,
                nutrientHighlight: nutrientHighlight(for: recipe),
                isAllergyFlagged: logReaction == "Alergi"
            )
            try logRepo?.addLog(newLog, to: baby.id)
            refreshLogState()
            showingLogSheet = false
            logNotes = ""
            selectedMealType = MealTypeHelper.inferredMealType(from: Date())
        } catch {
            print("Failed to save log: \(error)")
        }
    }

    private func nutrientHighlight(for recipe: RecipeItem) -> String {
        if recipe.protein >= 6.0 {
            return "Tinggi Protein"
        }
        if recipe.calories >= 200 {
            return "Padat Energi"
        }
        if recipe.fat <= 4.0 {
            return "Rendah Lemak"
        }
        return "Gizi Seimbang"
    }
}

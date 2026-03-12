//
//  ProfileViewModel.swift
//  iCipApp
//
//  Manages baby profile display, growth data, and profile reset.
//

import SwiftUI
import SwiftData
import Combine

// MARK: - Profile ViewModel
@MainActor
class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentBaby: Baby?
    @Published var showingResetAlert: Bool = false
    @Published var showingEditSheet: Bool = false
    
    // MARK: - Dependencies
    private var babyRepo: BabyRepositoryProtocol?
    
    // MARK: - Setup
    func configure(modelContext: ModelContext) {
        self.babyRepo = SwiftDataBabyRepository(context: modelContext)
        loadBaby()
    }
    
    // MARK: - Actions
    func loadBaby() {
        do {
            currentBaby = try babyRepo?.getBabies().first
        } catch {
            print("Failed to load baby: \(error)")
        }
    }
    
    /// Deletes the baby profile and all associated data.
    func resetProfile() {
        guard let baby = currentBaby else { return }
        do {
            try babyRepo?.deleteBaby(baby)
            currentBaby = nil
        } catch {
            print("Reset error: \(error)")
        }
    }
    
    /// Updates the baby profile data
    func updateBaby(name: String, dateOfBirth: Date, gender: String, allergies: [String]) {
        guard let baby = currentBaby else { return }
        baby.name = name
        baby.dateOfBirth = dateOfBirth
        baby.gender = gender
        baby.allergies = allergies
        
        do {
            try babyRepo?.updateBaby(baby)
            // Trigger UI update using objectWillChange since we modified object properties directly
            // when not using @Bindable in view.
            self.objectWillChange.send()
        } catch {
            print("Update error: \(error)")
        }
    }
    
    // MARK: - Computed Properties
    var foodLogCount: Int {
        currentBaby?.foodLogs.count ?? 0
    }
    
    var latestMeasurement: GrowthMeasurement? {
        currentBaby?.measurements.last
    }
}

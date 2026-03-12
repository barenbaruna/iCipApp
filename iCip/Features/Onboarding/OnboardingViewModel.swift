//
//  OnboardingViewModel.swift
//  iCipApp
//
//  Handles baby profile creation during onboarding.
//

import SwiftUI
import SwiftData
import Combine

// MARK: - Onboarding ViewModel
@MainActor
class OnboardingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var babyName: String = ""
    @Published var birthDate: Date = Date()
    @Published var gender: String = "Laki-laki"
    @Published var selectedAllergies: Set<String> = []
    @Published var initialWeight: String = ""
    @Published var initialHeight: String = ""
    @Published var showAllergenSheet = false
    @Published var showResultSheet = false
    @Published var savedBaby: Baby? = nil
    
    // MARK: - Constants
    let commonAllergens = ["Susu", "Telur", "Kacang Tanah", "Kedelai", "Ikan", "Shellfish", "Kacang Pohon", "Gandum", "Wijen", "Seledri", "Mustard", "Lupin", "Moluska", "Sulfit"]
    let genders = ["Laki-laki", "Perempuan"]
    
    // MARK: - Dependencies
    var repository: BabyRepositoryProtocol?
    
    // MARK: - Computed Properties
    var isFormValid: Bool {
        !babyName.isEmpty && Double(initialWeight.replacingOccurrences(of: ",", with: ".")) != nil && Double(initialHeight.replacingOccurrences(of: ",", with: ".")) != nil
    }
    
    // MARK: - Actions
    /// Creates the baby in memory and shows the result sheet.
    /// Does NOT persist to SwiftData yet (to avoid AppRouter race condition).
    func saveProfile() {
        guard isFormValid else { return }
        
        let weight = Double(initialWeight.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        let height = Double(initialHeight.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        let newBaby = Baby(
            name: babyName,
            dateOfBirth: birthDate,
            gender: gender,
            allergies: Array(selectedAllergies)
        )
        
        let initialMeasurement = GrowthMeasurement(weightKg: weight, heightCm: height)
        newBaby.measurements.append(initialMeasurement)
        
        savedBaby = newBaby
        showResultSheet = true
    }
    
    /// Actually persists the baby to SwiftData. Called when the user
    /// dismisses the result sheet via CTA.
    func persistBaby() {
        guard let baby = savedBaby else { return }
        baby.hasSeenInitialAnalysis = true
        do {
            try repository?.addBaby(baby)
        } catch {
            print("Failed to save baby: \(error)")
        }
    }
    
    func toggleAllergen(_ allergen: String) {
        if selectedAllergies.contains(allergen) {
            selectedAllergies.remove(allergen)
        } else {
            selectedAllergies.insert(allergen)
        }
    }
}

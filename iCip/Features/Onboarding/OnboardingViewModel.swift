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
    @Published var birthDate: Date? = nil
    @Published var gender: String = "Laki-laki"
    @Published var selectedAllergies: Set<String> = []
    @Published var initialWeight: String = ""
    @Published var initialHeight: String = ""
    @Published var showAllergenSheet = false
    
    // MARK: - Constants
    let commonAllergens = ["Susu", "Telur", "Kacang Tanah", "Kedelai", "Ikan", "Shellfish", "Kacang Pohon", "Gandum", "Wijen", "Seledri", "Mustard", "Lupin", "Moluska", "Sulfit"]
    let genders = ["Laki-laki", "Perempuan"]
    
    // MARK: - Dependencies
    var repository: BabyRepositoryProtocol?
    
    // MARK: - Computed Properties
    var isFormValid: Bool {
        !babyName.isEmpty && birthDate != nil && Double(initialWeight.replacingOccurrences(of: ",", with: ".")) != nil && Double(initialHeight.replacingOccurrences(of: ",", with: ".")) != nil
    }
    
    // MARK: - Actions
    
    /// Creates a plain BabyProfileData struct for the result sheet.
    /// Does NOT save anything to SwiftData so AppRouter won't transition yet.
    func createProfileData() -> BabyProfileData? {
        guard isFormValid, let validBirthDate = birthDate else { return nil }
        
        let weight = Double(initialWeight.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        let height = Double(initialHeight.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        return BabyProfileData(
            name: babyName,
            dateOfBirth: validBirthDate,
            gender: gender,
            allergies: Array(selectedAllergies),
            weightKg: weight,
            heightCm: height
        )
    }
    
    /// Persists the profile to SwiftData. Called AFTER the result sheet is dismissed.
    /// This triggers AppRouter to detect the baby and transition to MainTabView.
    func persistProfile(_ profileData: BabyProfileData) {
        let newBaby = Baby(
            name: profileData.name,
            dateOfBirth: profileData.dateOfBirth,
            gender: profileData.gender,
            allergies: profileData.allergies
        )
        newBaby.hasSeenInitialAnalysis = true
        
        let measurement = GrowthMeasurement(weightKg: profileData.weightKg, heightCm: profileData.heightCm)
        newBaby.measurements.append(measurement)
        
        do {
            try repository?.addBaby(newBaby)
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

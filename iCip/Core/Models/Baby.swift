//
//  Baby.swift
//  iCip
//

import Foundation
import SwiftData

@Model
final class Baby {
    var id: UUID = UUID()
    var name: String
    var dateOfBirth: Date
    var gender: String // "Male" or "Female"
    var allergies: [String] // e.g., "Telur", "Ayam", "Seafood"
    var hasSeenInitialAnalysis: Bool = false
    
    @Relationship(deleteRule: .cascade)
    var measurements: [GrowthMeasurement] = []
    
    @Relationship(deleteRule: .cascade)
    var foodLogs: [FoodLog] = []

    init(name: String, dateOfBirth: Date, gender: String, allergies: [String] = []) {
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.allergies = allergies
    }
    
    // Computed property to calculate age in months
    var ageInMonths: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: dateOfBirth, to: Date())
        return components.month ?? 0
    }

    /// Returns age in completed months at a specific date.
    func ageInMonths(at date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: dateOfBirth, to: date)
        return max(0, components.month ?? 0)
    }
}


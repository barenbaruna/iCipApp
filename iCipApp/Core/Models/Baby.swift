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
}

@Model
final class GrowthMeasurement {
    var id: UUID = UUID()
    var date: Date
    var weightKg: Double
    var heightCm: Double

    init(weightKg: Double, heightCm: Double, date: Date = Date()) {
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.date = date
    }
}

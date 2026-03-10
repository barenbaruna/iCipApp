//
//  RecipeItem.swift
//  iCipApp
//
//  Data model for Kemenkes recipes loaded from foods.json
//

import Foundation

// MARK: - Recipe Item
struct RecipeItem: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let ageMinimumMonths: Int
    let ageMaximumMonths: Int
    let texture: String
    let calories: Double
    let protein: Double
    let fat: Double
    let ingredients: [String]
    let allergens: [String]
    let preparationSteps: [String]
    let imageUrl: String?
}

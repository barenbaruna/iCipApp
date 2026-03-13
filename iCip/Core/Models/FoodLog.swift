//
//  FoodLog.swift
//  iCip
//

import Foundation
import SwiftData

enum MealTypeHelper {
    static let sarapan = "Sarapan"
    static let selinganPagi = "Selingan Pagi"
    static let makanSiang = "Makan Siang"
    static let selinganSore = "Selingan Sore"
    static let makanMalam = "Makan Malam"

    static let allOptions: [String] = [
        sarapan,
        selinganPagi,
        makanSiang,
        selinganSore,
        makanMalam,
    ]

    static func inferredMealType(from date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<10:
            return sarapan
        case 10..<12:
            return selinganPagi
        case 12..<15:
            return makanSiang
        case 15..<18:
            return selinganSore
        default:
            return makanMalam
        }
    }

    static func normalized(_ rawType: String) -> String {
        switch rawType {
        case "Makan Sore":
            return selinganSore
        case "Selingan":
            return selinganPagi
        default:
            return rawType
        }
    }
}

@Model
final class FoodLog {
    var id: UUID = UUID()
    var date: Date
    var recipeId: String
    var reaction: String // "Suka", "Tidak Suka", "Alergi"
    var notes: String
    var mealType: String // "Sarapan", "Selingan Pagi", "Makan Siang", "Selingan Sore", "Makan Malam"
    var foodName: String
    var nutrientHighlight: String // e.g. "Tinggi Protein", "Kaya Zat Besi"
    var isAllergyFlagged: Bool

        init(recipeId: String, reaction: String, notes: String = "", date: Date = Date(),
            mealType: String = MealTypeHelper.sarapan, foodName: String = "", nutrientHighlight: String = "",
         isAllergyFlagged: Bool = false) {
        self.recipeId = recipeId
        self.reaction = reaction
        self.notes = notes
        self.date = date
        self.mealType = MealTypeHelper.normalized(mealType)
        self.foodName = foodName
        self.nutrientHighlight = nutrientHighlight
        self.isAllergyFlagged = isAllergyFlagged
    }
}

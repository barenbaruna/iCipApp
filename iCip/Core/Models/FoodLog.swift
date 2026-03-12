//
//  FoodLog.swift
//  iCip
//

import Foundation
import SwiftData

@Model
final class FoodLog {
    var id: UUID = UUID()
    var date: Date
    var recipeId: String
    var reaction: String // "Suka", "Tidak Suka", "Alergi"
    var notes: String
    var mealType: String // "Sarapan", "Makan Siang", "Makan Sore", "Selingan"
    var foodName: String
    var nutrientHighlight: String // e.g. "Tinggi Protein", "Kaya Zat Besi"
    var isAllergyFlagged: Bool

    init(recipeId: String, reaction: String, notes: String = "", date: Date = Date(),
         mealType: String = "Sarapan", foodName: String = "", nutrientHighlight: String = "",
         isAllergyFlagged: Bool = false) {
        self.recipeId = recipeId
        self.reaction = reaction
        self.notes = notes
        self.date = date
        self.mealType = mealType
        self.foodName = foodName
        self.nutrientHighlight = nutrientHighlight
        self.isAllergyFlagged = isAllergyFlagged
    }
}

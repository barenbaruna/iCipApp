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

    init(recipeId: String, reaction: String, notes: String = "", date: Date = Date()) {
        self.recipeId = recipeId
        self.reaction = reaction
        self.notes = notes
        self.date = date
    }
}

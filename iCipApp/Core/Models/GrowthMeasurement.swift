//
//  GrowthMeasurement.swift
//  iCipApp
//
//  Created by Zildjian Vito  on 11/03/26.
//

import Foundation
import SwiftData

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

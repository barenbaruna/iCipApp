//
//  RiwayatViewModel.swift
//  iCipApp
//
//  Manages growth data, Z-score calculations, and food log history.
//

import SwiftUI
import SwiftData
import Combine

// MARK: - Riwayat ViewModel
@MainActor
class RiwayatViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentBaby: Baby?
    @Published var selectedIndicator: GrowthIndicator = .weightForAge
    @Published var showInputSheet = false
    @Published var selectedFoodLog: FoodLog?
    
    // Input fields
    @Published var inputWeight: String = ""
    @Published var inputHeight: String = ""
    @Published var selectedDate: Date = Date()
    
    // MARK: - Dependencies
    private var babyRepo: BabyRepositoryProtocol?
    private var modelContext: ModelContext?
    
    // MARK: - Setup
    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.babyRepo = SwiftDataBabyRepository(context: modelContext)
        loadBaby()
    }
    
    func loadBaby() {
        do {
            currentBaby = try babyRepo?.getBabies().first
        } catch {
            print("Failed to load baby: \(error)")
        }
    }
    
    // MARK: - Growth Data
    var sortedMeasurements: [GrowthMeasurement] {
        currentBaby?.measurements.sorted(by: { $0.date < $1.date }) ?? []
    }
    
    var latestMeasurement: GrowthMeasurement? {
        sortedMeasurements.last
    }
    
    var isMale: Bool {
        currentBaby?.gender == "Laki-laki"
    }
    
    // MARK: - Z-Score Calculations
    var weightForAgeZ: Double? {
        guard let m = latestMeasurement, let baby = currentBaby else { return nil }
        return WHOZScoreCalculator.weightForAgeZ(weightKg: m.weightKg, ageMonths: baby.ageInMonths, isMale: isMale)
    }
    
    var heightForAgeZ: Double? {
        guard let m = latestMeasurement, let baby = currentBaby else { return nil }
        return WHOZScoreCalculator.heightForAgeZ(heightCm: m.heightCm, ageMonths: baby.ageInMonths, isMale: isMale)
    }
    
    var weightForHeightZ: Double? {
        guard let m = latestMeasurement else { return nil }
        return WHOZScoreCalculator.weightForHeightZ(weightKg: m.weightKg, heightCm: m.heightCm, isMale: isMale)
    }
    
    func zScore(for indicator: GrowthIndicator) -> Double? {
        switch indicator {
        case .weightForAge: return weightForAgeZ
        case .heightForAge: return heightForAgeZ
        case .weightForHeight: return weightForHeightZ
        }
    }
    
    var overallStatus: GrowthStatus {
        WHOZScoreCalculator.overallStatus(wfaZ: weightForAgeZ, hfaZ: heightForAgeZ, wfhZ: weightForHeightZ)
    }
    
    var hasStuntingRisk: Bool {
        [weightForAgeZ, heightForAgeZ, weightForHeightZ].compactMap { $0 }.contains(where: { $0 < -2 })
    }
    
    var hasAttentionNeeded: Bool {
        [weightForAgeZ, heightForAgeZ, weightForHeightZ].compactMap { $0 }.contains(where: { $0 < -1 })
    }
    
    // MARK: - Chart Data Points
    struct ChartDataPoint: Identifiable {
        let id = UUID()
        let x: Double // age in months or height in cm
        let y: Double // measurement value
        let isLatest: Bool
    }
    
    func chartDataPoints(for indicator: GrowthIndicator) -> [ChartDataPoint] {
        guard let baby = currentBaby else { return [] }
        let measurements = sortedMeasurements
        let count = measurements.count
        
        return measurements.enumerated().map { index, m in
            let calendar = Calendar.current
            let ageMonths = calendar.dateComponents([.month], from: baby.dateOfBirth, to: m.date).month ?? 0
            
            switch indicator {
            case .weightForAge:
                return ChartDataPoint(x: Double(ageMonths), y: m.weightKg, isLatest: index == count - 1)
            case .heightForAge:
                return ChartDataPoint(x: Double(ageMonths), y: m.heightCm, isLatest: index == count - 1)
            case .weightForHeight:
                return ChartDataPoint(x: m.heightCm, y: m.weightKg, isLatest: index == count - 1)
            }
        }
    }
    
    /// Generate Z-score reference line values across the age range
    struct ReferenceLine: Identifiable {
        let id = UUID()
        let zScore: Double
        let points: [(x: Double, y: Double)]
    }
    
    func referenceLines(for indicator: GrowthIndicator) -> [ReferenceLine] {
        let zValues: [Double] = [-3, -2, -1, 0, 1, 2]
        let table: [LMSDataPoint]
        
        switch indicator {
        case .weightForAge:
            table = isMale ? WHOZScoreCalculator.wfaBoys : WHOZScoreCalculator.wfaGirls
        case .heightForAge:
            table = isMale ? WHOZScoreCalculator.hfaBoys : WHOZScoreCalculator.hfaGirls
        case .weightForHeight:
            table = isMale ? WHOZScoreCalculator.wfhBoys : WHOZScoreCalculator.wfhGirls
        }
        
        return zValues.map { z in
            let points: [(x: Double, y: Double)] = table.compactMap { lms in
                let value: Double
                if abs(lms.L) < 0.001 {
                    value = lms.M * exp(z * lms.S)
                } else {
                    let inner = 1 + lms.L * lms.S * z
                    guard inner > 0 else { return nil }
                    value = lms.M * pow(inner, 1.0 / lms.L)
                }
                return (x: Double(lms.ageMonths), y: value)
            }
            return ReferenceLine(zScore: z, points: points)
        }
    }
    
    // MARK: - Z-Score Band Areas for chart
    struct BandArea: Identifiable {
        let id = UUID()
        let lowerPoints: [(x: Double, y: Double)]
        let upperPoints: [(x: Double, y: Double)]
        let color: Color
    }
    
    func bandAreas(for indicator: GrowthIndicator) -> [BandArea] {
        let lines = referenceLines(for: indicator)
        guard lines.count == 6 else { return [] }
        // lines are sorted: -3, -2, -1, 0, 1, 2
        let colors: [Color] = [
            Color(hex: "#E53935").opacity(0.15),  // < -3 to -2: red
            Color(hex: "#FF9800").opacity(0.15),  // -2 to -1: orange
            Color(hex: "#FFB300").opacity(0.15),  // -1 to 0: yellow
            Color(hex: "#4CAF50").opacity(0.15),  // 0 to 1: green
            Color(hex: "#1E88E5").opacity(0.15),  // 1 to 2: blue
        ]
        
        var bands: [BandArea] = []
        for i in 0..<5 {
            let lower = lines[i]
            let upper = lines[i + 1]
            // Only include matching x values
            let lowerDict = Dictionary(uniqueKeysWithValues: lower.points.map { ($0.x, $0.y) })
            let upperDict = Dictionary(uniqueKeysWithValues: upper.points.map { ($0.x, $0.y) })
            let commonX = Set(lowerDict.keys).intersection(Set(upperDict.keys)).sorted()
            
            let lowerPts = commonX.map { (x: $0, y: lowerDict[$0]!) }
            let upperPts = commonX.map { (x: $0, y: upperDict[$0]!) }
            
            bands.append(BandArea(lowerPoints: lowerPts, upperPoints: upperPts, color: colors[i]))
        }
        return bands
    }
    
    // MARK: - Food Log
    var foodLogsByDate: [(date: Date, logs: [FoodLog])] {
        guard let baby = currentBaby else { return [] }
        let logs = baby.foodLogs.sorted(by: { $0.date > $1.date })
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: logs) { log in
            calendar.startOfDay(for: log.date)
        }
        return grouped.sorted(by: { $0.key > $1.key }).map { (date: $0.key, logs: $0.value) }
    }
    
    // MARK: - Actions
    func addMeasurement() {
        guard let baby = currentBaby,
              let weight = Double(inputWeight.replacingOccurrences(of: ",", with: ".")),
              let height = Double(inputHeight.replacingOccurrences(of: ",", with: ".")),
              weight > 0, height > 0
        else { return }
        
        let measurement = GrowthMeasurement(weightKg: weight, heightCm: height, date: selectedDate)
        baby.measurements.append(measurement)
        
        do {
            try modelContext?.save()
            
            // Scheduling reminders after successful save
            NotificationManager.shared.cancelGrowthReminders()
            NotificationManager.shared.scheduleMonthlyGrowthReminders(for: baby)
            
            loadBaby()
            inputWeight = ""
            inputHeight = ""
            selectedDate = Date()
            showInputSheet = false
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            print("Failed to save measurement: \(error)")
        }
    }
    
    func getRecipe(for log: FoodLog) -> RecipeItem? {
        try? LocalRecipeRepository.shared.getAllRecipes().first(where: { $0.id == log.recipeId })
    }
}

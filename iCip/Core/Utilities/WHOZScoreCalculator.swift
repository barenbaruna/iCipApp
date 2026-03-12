//
//  WHOZScoreCalculator.swift
//  iCipApp
//
//  WHO LMS reference tables and Z-score calculation.
//  Data source: WHO Child Growth Standards (0–60 months).
//

import SwiftUI

// MARK: - LMS Data Point
struct LMSDataPoint {
    let ageMonths: Int
    let L: Double
    let M: Double
    let S: Double
}

// MARK: - Growth Indicator
enum GrowthIndicator: String, CaseIterable, Identifiable {
    case weightForAge = "BB/U"
    case heightForAge = "TB/U"
    case weightForHeight = "BB/TB"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .weightForAge: return "Berat / Usia"
        case .heightForAge: return "Tinggi / Usia"
        case .weightForHeight: return "Berat / Tinggi"
        }
    }
    
    var yAxisLabel: String {
        switch self {
        case .weightForAge: return "Berat (kg)"
        case .heightForAge: return "Tinggi (cm)"
        case .weightForHeight: return "Berat (kg)"
        }
    }
    
    var xAxisLabel: String {
        switch self {
        case .weightForAge, .heightForAge: return "Usia (bulan)"
        case .weightForHeight: return "Tinggi (cm)"
        }
    }
}

// MARK: - Growth Status
enum GrowthStatus: String {
    case normal = "Normal"
    case needsAttention = "Perlu Perhatian"
    case stuntingRisk = "Risiko Stunting"
    case overweight = "Berat Badan Lebih"
    case obese = "Obesitas"
    
    var color: Color {
        switch self {
        case .normal: return AppColors.greenMain
        case .needsAttention: return AppColors.warningYellow
        case .stuntingRisk: return AppColors.alertRed
        case .overweight: return AppColors.warningYellow
        case .obese: return AppColors.alertRed
        }
    }
    
    var tintColor: Color {
        switch self {
        case .normal: return AppColors.greenTint
        case .needsAttention: return AppColors.warningYellowTint
        case .stuntingRisk: return AppColors.alertRedTint
        case .overweight: return AppColors.warningYellowTint
        case .obese: return AppColors.alertRedTint
        }
    }
    
    var icon: String {
        switch self {
        case .normal: return "checkmark.shield.fill"
        case .needsAttention: return "exclamationmark.triangle.fill"
        case .stuntingRisk: return "exclamationmark.octagon.fill"
        case .overweight: return "arrow.up.circle.fill"
        case .obese: return "exclamationmark.octagon.fill"
        }
    }
    
    var description: String {
        switch self {
        case .normal: return "Pertumbuhan si kecil dalam batas normal."
        case .needsAttention: return "Ada indikator yang perlu diperhatikan. Konsultasikan dengan dokter anak."
        case .stuntingRisk: return "Ada risiko stunting. Segera konsultasikan dengan dokter anak untuk penanganan lebih lanjut."
        case .overweight: return "Berat badan di atas normal. Perhatikan porsi dan komposisi makanan."
        case .obese: return "Risiko obesitas. Segera konsultasikan dengan dokter anak untuk penyesuaian pola makan."
        }
    }
}

// MARK: - Z-Score Band
struct ZScoreBand {
    let lowerZ: Double
    let upperZ: Double
    let color: Color
    let label: String
}

let zScoreBands: [ZScoreBand] = [
    ZScoreBand(lowerZ: -4.0, upperZ: -3.0, color: Color(hex: "#E53935").opacity(0.25), label: "< -3"),
    ZScoreBand(lowerZ: -3.0, upperZ: -2.0, color: Color(hex: "#FF9800").opacity(0.25), label: "-3 to -2"),
    ZScoreBand(lowerZ: -2.0, upperZ: -1.0, color: Color(hex: "#FFB300").opacity(0.25), label: "-2 to -1"),
    ZScoreBand(lowerZ: -1.0, upperZ:  1.0, color: Color(hex: "#4CAF50").opacity(0.25), label: "-1 to +1"),
    ZScoreBand(lowerZ:  1.0, upperZ:  2.0, color: Color(hex: "#1E88E5").opacity(0.25), label: "+1 to +2"),
    ZScoreBand(lowerZ:  2.0, upperZ:  4.0, color: Color(hex: "#7B1FA2").opacity(0.25), label: "> +2"),
]

// MARK: - WHO Z-Score Calculator
struct WHOZScoreCalculator {
    
    /// Calculate Z-score using WHO LMS formula: Z = [(X/M)^L - 1] / (L × S)
    static func calculateZScore(value: Double, L: Double, M: Double, S: Double) -> Double {
        guard M > 0, S > 0 else { return 0 }
        if abs(L) < 0.001 {
            // When L ≈ 0, use logarithmic form: Z = ln(X/M) / S
            return log(value / M) / S
        }
        return (pow(value / M, L) - 1) / (L * S)
    }
    
    /// Get Z-score for Weight-for-Age
    static func weightForAgeZ(weightKg: Double, ageMonths: Int, isMale: Bool) -> Double? {
        let table = isMale ? wfaBoys : wfaGirls
        guard let lms = table.first(where: { $0.ageMonths == ageMonths }) else { return nil }
        return calculateZScore(value: weightKg, L: lms.L, M: lms.M, S: lms.S)
    }
    
    /// Get Z-score for Height-for-Age
    static func heightForAgeZ(heightCm: Double, ageMonths: Int, isMale: Bool) -> Double? {
        let table = isMale ? hfaBoys : hfaGirls
        guard let lms = table.first(where: { $0.ageMonths == ageMonths }) else { return nil }
        return calculateZScore(value: heightCm, L: lms.L, M: lms.M, S: lms.S)
    }
    
    /// Get Z-score for Weight-for-Height
    static func weightForHeightZ(weightKg: Double, heightCm: Double, isMale: Bool) -> Double? {
        let table = isMale ? wfhBoys : wfhGirls
        // Find closest height in table
        let roundedHeight = Int(round(heightCm))
        guard let lms = table.first(where: { $0.ageMonths == roundedHeight }) else { return nil }
        return calculateZScore(value: weightKg, L: lms.L, M: lms.M, S: lms.S)
    }
    
    /// Get growth status from a Z-score (WHO full classification)
    static func statusFromZScore(_ z: Double) -> GrowthStatus {
        if z < -2 { return .stuntingRisk }
        if z < -1 { return .needsAttention }
        if z > 3 { return .obese }
        if z > 2 { return .overweight }
        return .normal
    }
    
    /// Get overall status from all 3 Z-scores.
    /// Checks both extremes: lowest Z for undernutrition, BB/TB for overweight.
    /// WHO: BB/TB (weight-for-height) is the primary indicator for overweight/obesity.
    static func overallStatus(wfaZ: Double?, hfaZ: Double?, wfhZ: Double?) -> GrowthStatus {
        let scores = [wfaZ, hfaZ, wfhZ].compactMap { $0 }
        guard !scores.isEmpty else { return .normal }
        
        // Check for overweight/obesity first — WHO uses BB/TB (wfhZ) as primary indicator
        if let wfh = wfhZ {
            if wfh > 3 { return .obese }
            if wfh > 2 { return .overweight }
        }
        
        // Then check for undernutrition (worst/lowest Z-score)
        if let worst = scores.min() {
            if worst < -2 { return .stuntingRisk }
            if worst < -1 { return .needsAttention }
        }
        
        return .normal
    }
    
    /// Get color for a Z-score value
    static func colorForZScore(_ z: Double) -> Color {
        if z < -3 { return Color(hex: "#E53935") }       // red
        if z < -2 { return Color(hex: "#FF9800") }       // orange
        if z < -1 { return Color(hex: "#FFB300") }       // yellow
        if z <= 1 { return AppColors.greenMain }          // green
        if z <= 2 { return AppColors.infoBlue }           // blue
        return Color(hex: "#7B1FA2")                      // purple
    }
    
    /// Get status label for a Z-score
    static func labelForZScore(_ z: Double) -> String {
        if z < -3 { return "Sangat Kurang" }
        if z < -2 { return "Kurang" }
        if z < -1 { return "Perlu Perhatian" }
        if z <= 1 { return "Normal" }
        if z <= 2 { return "Di Atas Normal" }
        return "Sangat Tinggi"
    }
    
    /// Get tint (background) color for a Z-score
    static func tintColorForZScore(_ z: Double) -> Color {
        if z < -3 { return AppColors.alertRedTint }
        if z < -2 { return Color(hex: "#FFF3E0") }           // orange tint
        if z < -1 { return AppColors.warningYellowTint }
        if z <= 1 { return AppColors.greenTint }
        if z <= 2 { return AppColors.blueTint }
        return AppColors.purpleTint
    }
    
    /// Get the median (M) value for Z-score reference lines on the chart
    static func referenceValues(indicator: GrowthIndicator, ageMonths: Int, isMale: Bool) -> [(zScore: Double, value: Double)] {
        let zLines: [Double] = [-3, -2, -1, 0, 1, 2]
        let table: [LMSDataPoint]
        let key: Int
        
        switch indicator {
        case .weightForAge:
            table = isMale ? wfaBoys : wfaGirls
            key = ageMonths
        case .heightForAge:
            table = isMale ? hfaBoys : hfaGirls
            key = ageMonths
        case .weightForHeight:
            table = isMale ? wfhBoys : wfhGirls
            key = ageMonths
        }
        
        guard let lms = table.first(where: { $0.ageMonths == key }) else { return [] }
        
        return zLines.map { z in
            let value: Double
            if abs(lms.L) < 0.001 {
                value = lms.M * exp(z * lms.S)
            } else {
                value = lms.M * pow(1 + lms.L * lms.S * z, 1.0 / lms.L)
            }
            return (zScore: z, value: value)
        }
    }
    
    /// Food recommendations for stunting risk
    static var stuntingFoodRecommendations: [(nutrient: String, icon: String, foods: String)] {
        [
            (nutrient: "Protein", icon: "fish.fill", foods: "Telur, ikan, daging, tempe"),
            (nutrient: "Kalsium", icon: "cup.and.saucer.fill", foods: "Susu, keju, yogurt, brokoli"),
            (nutrient: "Zat Besi", icon: "leaf.fill", foods: "Hati ayam, bayam, kacang-kacangan"),
            (nutrient: "Zinc", icon: "bolt.fill", foods: "Daging merah, kacang, biji-bijian"),
        ]
    }
    
    // MARK: - WHO LMS Reference Data
    // Weight-for-Age (Boys), 0–24 months — WHO 2006
    static let wfaBoys: [LMSDataPoint] = [
        LMSDataPoint(ageMonths: 0,  L: 0.3487, M: 3.3464, S: 0.14602),
        LMSDataPoint(ageMonths: 1,  L: 0.2297, M: 4.4709, S: 0.13395),
        LMSDataPoint(ageMonths: 2,  L: 0.1970, M: 5.5675, S: 0.12385),
        LMSDataPoint(ageMonths: 3,  L: 0.1738, M: 6.3762, S: 0.11727),
        LMSDataPoint(ageMonths: 4,  L: 0.1553, M: 7.0023, S: 0.11316),
        LMSDataPoint(ageMonths: 5,  L: 0.1395, M: 7.5105, S: 0.10990),
        LMSDataPoint(ageMonths: 6,  L: 0.1257, M: 7.9340, S: 0.10652),
        LMSDataPoint(ageMonths: 7,  L: 0.1134, M: 8.2970, S: 0.10390),
        LMSDataPoint(ageMonths: 8,  L: 0.1021, M: 8.6151, S: 0.10165),
        LMSDataPoint(ageMonths: 9,  L: 0.0917, M: 8.9014, S: 0.09970),
        LMSDataPoint(ageMonths: 10, L: 0.0822, M: 9.1649, S: 0.09795),
        LMSDataPoint(ageMonths: 11, L: 0.0731, M: 9.4122, S: 0.09630),
        LMSDataPoint(ageMonths: 12, L: 0.0644, M: 9.6479, S: 0.09477),
        LMSDataPoint(ageMonths: 13, L: 0.0563, M: 9.8749, S: 0.09339),
        LMSDataPoint(ageMonths: 14, L: 0.0487, M: 10.0953, S: 0.09218),
        LMSDataPoint(ageMonths: 15, L: 0.0413, M: 10.3108, S: 0.09111),
        LMSDataPoint(ageMonths: 16, L: 0.0343, M: 10.5228, S: 0.09014),
        LMSDataPoint(ageMonths: 17, L: 0.0275, M: 10.7319, S: 0.08927),
        LMSDataPoint(ageMonths: 18, L: 0.0211, M: 10.9385, S: 0.08847),
        LMSDataPoint(ageMonths: 19, L: 0.0148, M: 11.1430, S: 0.08774),
        LMSDataPoint(ageMonths: 20, L: 0.0087, M: 11.3462, S: 0.08706),
        LMSDataPoint(ageMonths: 21, L: 0.0029, M: 11.5486, S: 0.08643),
        LMSDataPoint(ageMonths: 22, L: -0.0028, M: 11.7504, S: 0.08583),
        LMSDataPoint(ageMonths: 23, L: -0.0083, M: 11.9514, S: 0.08527),
        LMSDataPoint(ageMonths: 24, L: -0.0137, M: 12.1515, S: 0.08474),
    ]
    
    // Weight-for-Age (Girls), 0–24 months
    static let wfaGirls: [LMSDataPoint] = [
        LMSDataPoint(ageMonths: 0,  L: 0.3809, M: 3.2322, S: 0.14171),
        LMSDataPoint(ageMonths: 1,  L: 0.1714, M: 4.1873, S: 0.13724),
        LMSDataPoint(ageMonths: 2,  L: 0.0962, M: 5.1282, S: 0.12920),
        LMSDataPoint(ageMonths: 3,  L: 0.0402, M: 5.8458, S: 0.12296),
        LMSDataPoint(ageMonths: 4,  L: -0.0050, M: 6.4237, S: 0.11872),
        LMSDataPoint(ageMonths: 5,  L: -0.0430, M: 6.8985, S: 0.11552),
        LMSDataPoint(ageMonths: 6,  L: -0.0756, M: 7.2970, S: 0.11290),
        LMSDataPoint(ageMonths: 7,  L: -0.1039, M: 7.6422, S: 0.10999),
        LMSDataPoint(ageMonths: 8,  L: -0.1288, M: 7.9487, S: 0.10745),
        LMSDataPoint(ageMonths: 9,  L: -0.1507, M: 8.2254, S: 0.10518),
        LMSDataPoint(ageMonths: 10, L: -0.1700, M: 8.4800, S: 0.10313),
        LMSDataPoint(ageMonths: 11, L: -0.1872, M: 8.7192, S: 0.10123),
        LMSDataPoint(ageMonths: 12, L: -0.2024, M: 8.9481, S: 0.09951),
        LMSDataPoint(ageMonths: 13, L: -0.2158, M: 9.1699, S: 0.09796),
        LMSDataPoint(ageMonths: 14, L: -0.2278, M: 9.3870, S: 0.09658),
        LMSDataPoint(ageMonths: 15, L: -0.2384, M: 9.6008, S: 0.09534),
        LMSDataPoint(ageMonths: 16, L: -0.2478, M: 9.8124, S: 0.09422),
        LMSDataPoint(ageMonths: 17, L: -0.2562, M: 10.0226, S: 0.09321),
        LMSDataPoint(ageMonths: 18, L: -0.2637, M: 10.2315, S: 0.09228),
        LMSDataPoint(ageMonths: 19, L: -0.2703, M: 10.4393, S: 0.09143),
        LMSDataPoint(ageMonths: 20, L: -0.2762, M: 10.6464, S: 0.09065),
        LMSDataPoint(ageMonths: 21, L: -0.2815, M: 10.8534, S: 0.08992),
        LMSDataPoint(ageMonths: 22, L: -0.2862, M: 11.0608, S: 0.08924),
        LMSDataPoint(ageMonths: 23, L: -0.2903, M: 11.2688, S: 0.08860),
        LMSDataPoint(ageMonths: 24, L: -0.2941, M: 11.4775, S: 0.08800),
    ]
    
    // Height-for-Age (Boys), 0–24 months
    static let hfaBoys: [LMSDataPoint] = [
        LMSDataPoint(ageMonths: 0,  L: 1, M: 49.8842, S: 0.03795),
        LMSDataPoint(ageMonths: 1,  L: 1, M: 54.7244, S: 0.03557),
        LMSDataPoint(ageMonths: 2,  L: 1, M: 58.4249, S: 0.03424),
        LMSDataPoint(ageMonths: 3,  L: 1, M: 61.4292, S: 0.03328),
        LMSDataPoint(ageMonths: 4,  L: 1, M: 63.8860, S: 0.03257),
        LMSDataPoint(ageMonths: 5,  L: 1, M: 65.9026, S: 0.03204),
        LMSDataPoint(ageMonths: 6,  L: 1, M: 67.6236, S: 0.03165),
        LMSDataPoint(ageMonths: 7,  L: 1, M: 69.1645, S: 0.03139),
        LMSDataPoint(ageMonths: 8,  L: 1, M: 70.5994, S: 0.03124),
        LMSDataPoint(ageMonths: 9,  L: 1, M: 71.9687, S: 0.03117),
        LMSDataPoint(ageMonths: 10, L: 1, M: 73.2812, S: 0.03118),
        LMSDataPoint(ageMonths: 11, L: 1, M: 74.5388, S: 0.03126),
        LMSDataPoint(ageMonths: 12, L: 1, M: 75.7488, S: 0.03140),
        LMSDataPoint(ageMonths: 13, L: 1, M: 76.9186, S: 0.03159),
        LMSDataPoint(ageMonths: 14, L: 1, M: 78.0497, S: 0.03183),
        LMSDataPoint(ageMonths: 15, L: 1, M: 79.1458, S: 0.03209),
        LMSDataPoint(ageMonths: 16, L: 1, M: 80.2113, S: 0.03238),
        LMSDataPoint(ageMonths: 17, L: 1, M: 81.2487, S: 0.03268),
        LMSDataPoint(ageMonths: 18, L: 1, M: 82.2587, S: 0.03300),
        LMSDataPoint(ageMonths: 19, L: 1, M: 83.2418, S: 0.03333),
        LMSDataPoint(ageMonths: 20, L: 1, M: 84.1996, S: 0.03366),
        LMSDataPoint(ageMonths: 21, L: 1, M: 85.1348, S: 0.03399),
        LMSDataPoint(ageMonths: 22, L: 1, M: 86.0477, S: 0.03433),
        LMSDataPoint(ageMonths: 23, L: 1, M: 86.9412, S: 0.03466),
        LMSDataPoint(ageMonths: 24, L: 1, M: 87.8161, S: 0.03499),
    ]
    
    // Height-for-Age (Girls), 0–24 months
    static let hfaGirls: [LMSDataPoint] = [
        LMSDataPoint(ageMonths: 0,  L: 1, M: 49.1477, S: 0.03790),
        LMSDataPoint(ageMonths: 1,  L: 1, M: 53.6872, S: 0.03614),
        LMSDataPoint(ageMonths: 2,  L: 1, M: 57.0673, S: 0.03487),
        LMSDataPoint(ageMonths: 3,  L: 1, M: 59.8029, S: 0.03411),
        LMSDataPoint(ageMonths: 4,  L: 1, M: 62.0899, S: 0.03361),
        LMSDataPoint(ageMonths: 5,  L: 1, M: 64.0301, S: 0.03325),
        LMSDataPoint(ageMonths: 6,  L: 1, M: 65.7311, S: 0.03295),
        LMSDataPoint(ageMonths: 7,  L: 1, M: 67.2873, S: 0.03269),
        LMSDataPoint(ageMonths: 8,  L: 1, M: 68.7498, S: 0.03246),
        LMSDataPoint(ageMonths: 9,  L: 1, M: 70.1435, S: 0.03223),
        LMSDataPoint(ageMonths: 10, L: 1, M: 71.4818, S: 0.03201),
        LMSDataPoint(ageMonths: 11, L: 1, M: 72.7710, S: 0.03181),
        LMSDataPoint(ageMonths: 12, L: 1, M: 74.0153, S: 0.03163),
        LMSDataPoint(ageMonths: 13, L: 1, M: 75.2154, S: 0.03148),
        LMSDataPoint(ageMonths: 14, L: 1, M: 76.3723, S: 0.03137),
        LMSDataPoint(ageMonths: 15, L: 1, M: 77.4880, S: 0.03130),
        LMSDataPoint(ageMonths: 16, L: 1, M: 78.5639, S: 0.03127),
        LMSDataPoint(ageMonths: 17, L: 1, M: 79.6025, S: 0.03128),
        LMSDataPoint(ageMonths: 18, L: 1, M: 80.6051, S: 0.03133),
        LMSDataPoint(ageMonths: 19, L: 1, M: 81.5737, S: 0.03142),
        LMSDataPoint(ageMonths: 20, L: 1, M: 82.5108, S: 0.03154),
        LMSDataPoint(ageMonths: 21, L: 1, M: 83.4182, S: 0.03170),
        LMSDataPoint(ageMonths: 22, L: 1, M: 84.2964, S: 0.03188),
        LMSDataPoint(ageMonths: 23, L: 1, M: 85.1466, S: 0.03209),
        LMSDataPoint(ageMonths: 24, L: 1, M: 85.9695, S: 0.03232),
    ]
    
    // Weight-for-Height (Boys) — key is height in cm (45–110)
    static let wfhBoys: [LMSDataPoint] = [
        LMSDataPoint(ageMonths: 45, L: -0.3521, M: 2.441, S: 0.09182),
        LMSDataPoint(ageMonths: 50, L: -0.1684, M: 3.243, S: 0.09029),
        LMSDataPoint(ageMonths: 55, L: 0.0350, M: 4.316, S: 0.08676),
        LMSDataPoint(ageMonths: 60, L: 0.1475, M: 5.613, S: 0.08374),
        LMSDataPoint(ageMonths: 65, L: 0.1612, M: 6.947, S: 0.08175),
        LMSDataPoint(ageMonths: 70, L: 0.1275, M: 8.162, S: 0.08131),
        LMSDataPoint(ageMonths: 75, L: 0.0683, M: 9.253, S: 0.08221),
        LMSDataPoint(ageMonths: 80, L: 0.0068, M: 10.265, S: 0.08394),
        LMSDataPoint(ageMonths: 85, L: -0.0420, M: 11.249, S: 0.08588),
        LMSDataPoint(ageMonths: 90, L: -0.0843, M: 12.231, S: 0.08785),
        LMSDataPoint(ageMonths: 95, L: -0.1324, M: 13.239, S: 0.09004),
        LMSDataPoint(ageMonths: 100, L: -0.1888, M: 14.306, S: 0.09252),
        LMSDataPoint(ageMonths: 105, L: -0.2489, M: 15.466, S: 0.09533),
        LMSDataPoint(ageMonths: 110, L: -0.3068, M: 16.737, S: 0.09846),
    ]
    
    // Weight-for-Height (Girls) — key is height in cm (45–110)
    static let wfhGirls: [LMSDataPoint] = [
        LMSDataPoint(ageMonths: 45, L: -0.3833, M: 2.461, S: 0.09029),
        LMSDataPoint(ageMonths: 50, L: -0.1136, M: 3.178, S: 0.09104),
        LMSDataPoint(ageMonths: 55, L: 0.0576, M: 4.187, S: 0.08820),
        LMSDataPoint(ageMonths: 60, L: 0.1281, M: 5.441, S: 0.08540),
        LMSDataPoint(ageMonths: 65, L: 0.1390, M: 6.736, S: 0.08386),
        LMSDataPoint(ageMonths: 70, L: 0.1060, M: 7.948, S: 0.08371),
        LMSDataPoint(ageMonths: 75, L: 0.0539, M: 9.032, S: 0.08474),
        LMSDataPoint(ageMonths: 80, L: 0.0047, M: 10.034, S: 0.08633),
        LMSDataPoint(ageMonths: 85, L: -0.0333, M: 11.012, S: 0.08804),
        LMSDataPoint(ageMonths: 90, L: -0.0641, M: 11.985, S: 0.08970),
        LMSDataPoint(ageMonths: 95, L: -0.0966, M: 12.979, S: 0.09148),
        LMSDataPoint(ageMonths: 100, L: -0.1336, M: 14.023, S: 0.09350),
        LMSDataPoint(ageMonths: 105, L: -0.1744, M: 15.150, S: 0.09580),
        LMSDataPoint(ageMonths: 110, L: -0.2149, M: 16.387, S: 0.09845),
    ]
}

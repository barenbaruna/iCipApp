//
//  SwiftDataRepositories.swift
//  iCip
//

import Foundation
import SwiftData

@MainActor
class SwiftDataBabyRepository: BabyRepositoryProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func getBabies() throws -> [Baby] {
        let descriptor = FetchDescriptor<Baby>(sortBy: [SortDescriptor(\.name)])
        return try context.fetch(descriptor)
    }
    
    func addBaby(_ baby: Baby) throws {
        context.insert(baby)
        try context.save()
    }
    
    func deleteBaby(_ baby: Baby) throws {
        context.delete(baby)
        try context.save()
    }
    
    func updateBaby(_ baby: Baby) throws {
        try context.save()
    }
}

@MainActor
class SwiftDataLogRepository: FoodLogRepositoryProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func getLogs(for babyId: UUID) throws -> [FoodLog] {
        // Find the baby first
        let babyDescriptor = FetchDescriptor<Baby>(predicate: #Predicate { $0.id == babyId })
        guard let baby = try context.fetch(babyDescriptor).first else {
            return []
        }
        return baby.foodLogs.sorted(by: { $0.date > $1.date })
    }
    
    func addLog(_ log: FoodLog, to babyId: UUID) throws {
        let babyDescriptor = FetchDescriptor<Baby>(predicate: #Predicate { $0.id == babyId })
        if let baby = try context.fetch(babyDescriptor).first {
            baby.foodLogs.append(log)
            try context.save()
        } else {
            throw NSError(domain: "Baby not found", code: 404, userInfo: nil)
        }
    }
}

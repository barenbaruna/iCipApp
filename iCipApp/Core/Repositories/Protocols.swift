//
//  BabyRepositoryProtocol.swift
//  iCip
//

import Foundation

protocol BabyRepositoryProtocol {
    func getBabies() throws -> [Baby]
    func addBaby(_ baby: Baby) throws
    func deleteBaby(_ baby: Baby) throws
    func updateBaby(_ baby: Baby) throws
}

protocol FoodLogRepositoryProtocol {
    func getLogs(for babyId: UUID) throws -> [FoodLog]
    func addLog(_ log: FoodLog, to babyId: UUID) throws
}

protocol RecipeRepositoryProtocol {
    func getAllRecipes() throws -> [RecipeItem]
    func getRecipes(forAgeMonths age: Int) throws -> [RecipeItem]
}

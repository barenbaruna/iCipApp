//
//  iCipAppApp.swift
//  iCipApp
//
//  App entry point — SwiftData container + routing
//

import SwiftUI
import SwiftData

@main
struct iCipApp: App {
    
    // MARK: - Properties
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Baby.self,
            GrowthMeasurement.self,
            FoodLog.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            AppRouter()
        }
        .modelContainer(sharedModelContainer)
    }
}

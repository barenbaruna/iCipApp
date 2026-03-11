//
//  AppRouter.swift
//  iCipApp
//
//  Centralized routing: onboarding vs main app.
//  Future-proof for login flows, deep links, etc.
//

import SwiftUI
import SwiftData

// MARK: - App Router
struct AppRouter: View {
    
    // MARK: - Properties
    @Query private var babies: [Baby]
    
    // MARK: - Body
    var body: some View {
        Group {
            if babies.isEmpty {
                SplashView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: babies.isEmpty)
    }
}

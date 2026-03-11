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
    @State private var showSplash = true
    
    // MARK: - Body
    var body: some View {
        Group {
            if showSplash {
                SplashView {
                    showSplash = false
                }
                .transition(.opacity)
            } else {
                if babies.isEmpty {
                    OnboardingFlowView()
                        .transition(.opacity)
                } else {
                    MainTabView()
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
        .animation(.easeInOut(duration: 0.5), value: babies.isEmpty)
    }
}

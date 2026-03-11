//
//  OnboardingFlowView.swift
//  iCipApp
//
//  Orchestrates SplashView → LegalAgreement → OnboardingProfile with transitions.
//

import SwiftUI

// MARK: - Onboarding Flow View
struct OnboardingFlowView: View {
    
    // MARK: - Properties
    @State private var hasAcceptedLegal = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            if hasAcceptedLegal {
                OnboardingProfileView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                LegalAgreementView(hasAccepted: $hasAcceptedLegal)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: hasAcceptedLegal)
    }
}

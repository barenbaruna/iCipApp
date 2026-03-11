//
//  SplashView.swift
//  iCipApp
//
//  Splash Screen with animated logo and warm gradient
//

import SwiftUI

struct SplashView: View {
    // MARK: - Properties
    var onDismiss: (() -> Void)
    
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0.0
    @State private var taglineOpacity: Double = 0.0
    @State private var ringRotation: Double = 0
    
    // MARK: - Body
    var body: some View {
        splashContent
            .onAppear { animateSplash() }
    }
    
    // MARK: - Views
    private var splashContent: some View {
        ZStack {
            // Warm gradient background
            AppColors.warmGradient
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                // App icon
                Image("SplashLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: AppColors.orangeMain.opacity(0.3), radius: 20, x: 0, y: 10)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                // Tagline
                VStack(spacing: 8) {
                    Text("Tumbuh Baik Bersama")
                        .font(AppFonts.heading2())
                        .foregroundColor(AppColors.textDark)
                    
                    Text("Rekomendasi MPASI personal untuk si kecil")
                        .font(AppFonts.bodyRegular())
                        .foregroundColor(AppColors.textMidGray)
                        .multilineTextAlignment(.center)
                }
                .opacity(taglineOpacity)
                
                Spacer()
                
                // Kemenkes badge
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(AppColors.greenMain)
                        .font(.system(size: 14))
                    Text("Berbasis Panduan Kemenkes RI")
                        .font(AppFonts.caption())
                        .foregroundColor(AppColors.textMidGray)
                }
                .padding(.bottom, 40)
                .opacity(taglineOpacity)
            }
        }
    }
    
    // MARK: - Helpers
    private func animateSplash() {
        // Logo entrance
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Ring rotation
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }
        
        // Tagline fade in
        withAnimation(.easeIn(duration: 0.6).delay(0.4)) {
            taglineOpacity = 1.0
        }
        
        // Transition to main app or onboarding via router
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                onDismiss()
            }
        }
    }
}

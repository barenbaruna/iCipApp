//
//  LegalAgreementView.swift
//  iCipApp
//
//  Medical Disclaimer — Mandatory per PRD.
//  Apple HIG: haptic feedback, safe area, dark mode adaptive.
//

import SwiftUI

// MARK: - Legal Agreement View
struct LegalAgreementView: View {
    
    // MARK: - Properties
    @Binding var hasAccepted: Bool
    @State private var cardOpacity: Double = 0
    @State private var cardOffset: CGFloat = 30
    @State private var iconScale: CGFloat = 0.5
    
    // MARK: - Body
    var body: some View {
        ZStack {
            AppColors.creamWhite.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerIcon
                    
                    Text("Peringatan Medis")
                        .font(AppFonts.heading1())
                        .foregroundColor(AppColors.textDark)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    infoCard
                    
                    Spacer(minLength: 40)
                    
                    ctaButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .onAppear { animateEntrance() }
    }
    
    // MARK: - Header Icon
    private var headerIcon: some View {
        HStack {
            Spacer()
            ZStack {
                Circle()
                    .fill(AppColors.alertRedTint)
                    .frame(width: 80, height: 80)
                Image(systemName: "heart.text.clipboard.fill")
                    .font(.system(size: 36))
                    .foregroundColor(AppColors.alertRed)
            }
            .scaleEffect(iconScale)
            Spacer()
        }
        .padding(.top, 30)
    }
    
    // MARK: - Info Card
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            infoRow(icon: "book.pages.fill", color: AppColors.infoBlue,
                text: "Informasi iCip merujuk pada **Buku Resep Makanan Lokal Kemenkes RI 2023** dan murni edukatif, bukan pengganti nasihat medis profesional.",
                textColor: AppColors.textDark)
            
            Divider()
            
            infoRow(icon: "stethoscope", color: AppColors.orangeMain,
                text: "Kebutuhan bayi berbeda-beda. Selalu konsultasikan pola makan dengan dokter anak, khususnya jika ada **riwayat alergi** atau kondisi medis spesifik.",
                textColor: AppColors.textMidGray)
            
            Divider()
            
            infoRow(icon: "lock.shield.fill", color: AppColors.greenMain,
                text: "**Privasi Terpadu**. Data anak (seperti usia, fisik, & alergi) digunakan sebatas untuk personalisasi MPASI. Data disimpan *lokal* dan tidak dibagikan.",
                textColor: AppColors.textMidGray)
            
            Divider()
            
            infoRow(icon: "checkmark.seal.fill", color: AppColors.textSubtleGray,
                text: "Dengan melanjutkan, Anda memahami bahwa penggunaan informasi aplikasi sepenuhnya merupakan tanggung jawab pengguna secara mandiri.",
                textColor: AppColors.textMidGray)
        }
        .padding(20)
        .background(AppColors.cardWhite)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        .opacity(cardOpacity)
        .offset(y: cardOffset)
    }
    
    // MARK: - CTA Button
    private var ctaButton: some View {
        Button(action: {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                hasAccepted = true
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.shield.fill")
                Text("Saya Mengerti dan Setuju")
                    .font(AppFonts.ctaText())
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppColors.primaryGradient)
            .cornerRadius(12)
            .shadow(color: AppColors.orangeMain.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Helpers
    private func infoRow(icon: String, color: Color, text: String, textColor: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20))
            Text(.init(text))
                .font(AppFonts.bodyRegular())
                .foregroundColor(textColor)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func animateEntrance() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            iconScale = 1.0
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            cardOpacity = 1.0
            cardOffset = 0
        }
    }
}

#Preview {
    @Previewable @State var hasAccepted = false
    LegalAgreementView(hasAccepted: $hasAccepted)
}

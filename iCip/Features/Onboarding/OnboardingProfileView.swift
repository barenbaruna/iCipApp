//
//  OnboardingProfileView.swift
//  iCipApp
//
//  Baby Profile Setup — Multi-step onboarding form
//  Apple HIG: Keyboard dismissal, safe area, haptic feedback, dark mode
//

import Combine
import SwiftData
import SwiftUI

// MARK: - Onboarding Profile View
struct OnboardingProfileView: View {

    // MARK: - Properties
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var animateIn = false
    @State private var showDatePicker = false
    @State private var hasSelectedDate = false

    // MARK: - Body
    var body: some View {
        ZStack {
            AppColors.creamWhite.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    nameInput
                    dobInput
                    genderInput
                    measurementInput
                    allergySection
                    ctaButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onTapGesture { hideKeyboard() }
        .sheet(
            isPresented: $viewModel.showResultSheet,
            onDismiss: {
                viewModel.persistBaby()
            }
        ) {
            if let baby = viewModel.savedBaby {
                OnboardingResultView(baby: baby) {
                    viewModel.showResultSheet = false
                }
                .presentationDetents([.large])
                .interactiveDismissDisabled()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { animateIn = true }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.orangeMain)
                    .scaleEffect(animateIn ? 1.0 : 0.5)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: animateIn)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Profil Si Kecil")
                        .font(AppFonts.heading1())
                        .foregroundColor(AppColors.textDark)
                    Text("Yuk kenalan agar iCip bisa memberikan rekomendasi paling tepat!")
                        .font(AppFonts.bodyRegular())
                        .foregroundColor(AppColors.textMidGray)
                }
            }
        }
        .padding(.top, 12)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 15)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: animateIn)
    }

    // MARK: - Name Input
    private var nameInput: some View {
        inputSection(title: "Nama Bayi", icon: "person.fill") {
            TextField("Masukkan nama si kecil", text: $viewModel.babyName)
                .font(AppFonts.bodyRegular())
                .foregroundColor(AppColors.inputText)
                .padding(14)
                .background(AppColors.inputBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            viewModel.babyName.isEmpty
                                ? Color.clear : AppColors.orangeMain.opacity(0.4), lineWidth: 1)
                )
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 15)
        .animation(.easeOut(duration: 0.5).delay(0.15), value: animateIn)
    }

    // MARK: - Date of Birth
    private var dobInput: some View {
        inputSection(title: "Tanggal Lahir", icon: "calendar") {
            Button(action: {
                showDatePicker = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }) {
                HStack {
                    if hasSelectedDate {
                        Text(viewModel.birthDate.formatted(date: .long, time: .omitted))
                            .font(AppFonts.bodyRegular())
                            .foregroundColor(AppColors.orangeMain)
                    } else {
                        Text("Masukkan tanggal lahir si kecil")
                            .font(AppFonts.bodyRegular())
                            .foregroundColor(AppColors.textSubtleGray)
                    }
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(
                            hasSelectedDate ? AppColors.orangeMain : AppColors.textSubtleGray
                        )
                        .font(.body)
                }
                .padding(14)
                .background(AppColors.inputBackground)
                .cornerRadius(12)
            }
            .sheet(isPresented: $showDatePicker) {
                VStack(spacing: 0) {
                    HStack {
                        Text("Tanggal Lahir")
                            .font(AppFonts.heading2())
                            .foregroundColor(AppColors.textDark)
                        Spacer()
                        Button("Selesai") {
                            hasSelectedDate = true
                            showDatePicker = false
                        }
                        .font(AppFonts.bodyRegular())
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.orangeMain)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 8)

                    DatePicker(
                        "",
                        selection: $viewModel.birthDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .tint(AppColors.orangeMain)
                    .padding(.horizontal, 16)

                    Spacer()
                }
                .background(AppColors.creamWhite.ignoresSafeArea())
                .presentationDetents([.medium])
                .presentationCornerRadius(24)
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 15)
        .animation(.easeOut(duration: 0.5).delay(0.2), value: animateIn)
    }

    // MARK: - Gender
    private var genderInput: some View {
        inputSection(title: "Jenis Kelamin", icon: "figure.and.child.halved.filled") {
            HStack(spacing: 12) {
                ForEach(viewModel.genders, id: \.self) { gender in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) { viewModel.gender = gender }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        HStack(spacing: 8) {
                            Image(
                                systemName: gender == "Laki-laki"
                                    ? "figure.stand" : "figure.stand.dress"
                            )
                            .font(.system(size: 16))
                            Text(gender)
                                .font(AppFonts.bodyRegular())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            viewModel.gender == gender
                                ? AppColors.orangeTint : AppColors.inputBackground
                        )
                        .foregroundColor(
                            viewModel.gender == gender
                                ? AppColors.orangeMain : AppColors.textMidGray
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    viewModel.gender == gender ? AppColors.orangeMain : Color.clear,
                                    lineWidth: 1.5)
                        )
                        .scaleEffect(viewModel.gender == gender ? 1.02 : 1.0)
                    }
                }
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 15)
        .animation(.easeOut(duration: 0.5).delay(0.25), value: animateIn)
    }

    // MARK: - Measurements
    private var measurementInput: some View {
        inputSection(title: "Data Pertumbuhan Awal", icon: "ruler") {
            HStack(spacing: 12) {
                measurementField(
                    label: "Berat (kg)", placeholder: "7.5", text: $viewModel.initialWeight)
                measurementField(
                    label: "Tinggi (cm)", placeholder: "65.0", text: $viewModel.initialHeight)
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 15)
        .animation(.easeOut(duration: 0.5).delay(0.3), value: animateIn)
    }

    // MARK: - Allergy Section
    private var allergySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "allergens")
                    .foregroundColor(AppColors.alertRed)
                    .font(.system(size: 14))
                Text("Riwayat Alergi")
                    .font(AppFonts.heading3())
                    .foregroundColor(AppColors.textDark)
            }

            Text("Tandai jika ada riwayat alergi (opsional)")
                .font(AppFonts.caption())
                .foregroundColor(AppColors.textSubtleGray)

            Button(action: {
                viewModel.showAllergenSheet = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }) {
                HStack {
                    Text("Pilih riwayat alergi")
                        .font(AppFonts.bodyRegular())
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                }
                .foregroundColor(AppColors.textDark)
                .padding(14)
                .background(AppColors.inputBackground)
                .cornerRadius(12)
            }

            if !viewModel.selectedAllergies.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(viewModel.selectedAllergies).sorted(), id: \.self) {
                            allergen in
                            HStack(spacing: 4) {
                                Text(allergen)
                                    .font(AppFonts.caption())
                                    .foregroundColor(AppColors.alertRed)

                                Button(action: {
                                    viewModel.toggleAllergen(allergen)
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(AppColors.alertRed)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.alertRedTint)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.alertRed.opacity(0.5), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 15)
        .animation(.easeOut(duration: 0.5).delay(0.35), value: animateIn)
        .sheet(isPresented: $viewModel.showAllergenSheet) {
            AllergenSelectionSheet(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
    }

    // MARK: - CTA Button
    private var ctaButton: some View {
        Button(action: {
            viewModel.repository = SwiftDataBabyRepository(context: modelContext)
            viewModel.saveProfile()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.right.circle.fill")
                Text("Selesai & Mulai Eksplor")
                    .font(AppFonts.ctaText())
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                viewModel.isFormValid
                    ? AppColors.primaryGradient
                    : LinearGradient(
                        colors: [AppColors.surfaceGray], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(12)
            .shadow(
                color: viewModel.isFormValid ? AppColors.orangeMain.opacity(0.3) : Color.clear,
                radius: 8, x: 0, y: 4)
        }
        .disabled(!viewModel.isFormValid)
        .padding(.top, 16)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 15)
        .animation(.easeOut(duration: 0.5).delay(0.4), value: animateIn)
    }

    // MARK: - Reusable Components
    private func inputSection<Content: View>(
        title: String, icon: String, @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(AppColors.orangeMain)
                    .font(.system(size: 14))
                Text(title)
                    .font(AppFonts.heading3())
                    .foregroundColor(AppColors.textDark)
            }
            content()
        }
    }

    private func measurementField(label: String, placeholder: String, text: Binding<String>)
        -> some View
    {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(AppFonts.caption())
                .foregroundColor(AppColors.textMidGray)
            TextField(placeholder, text: text)
                .keyboardType(.numbersAndPunctuation)
                .font(AppFonts.bodyRegular())
                .foregroundColor(AppColors.inputText)
                .padding(14)
                .background(AppColors.inputBackground)
                .cornerRadius(12)
        }
    }

    // MARK: - Helpers
    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Allergen Selection Sheet
struct AllergenSelectionSheet: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.commonAllergens, id: \.self) { allergen in
                    Button(action: {
                        viewModel.toggleAllergen(allergen)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        HStack {
                            Text(allergen)
                                .font(AppFonts.bodyRegular())
                                .foregroundColor(AppColors.textDark)
                            Spacer()
                            if viewModel.selectedAllergies.contains(allergen) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.orangeMain)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Pilih Riwayat Alergi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Selesai") {
                        dismiss()
                    }
                    .font(AppFonts.bodyRegular())
                    .foregroundColor(AppColors.orangeMain)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

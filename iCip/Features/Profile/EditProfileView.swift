//
//  EditProfileView.swift
//  iCipApp
//
//  Form to edit baby profile data
//

import SwiftUI

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var gender: String = "Laki-laki"
    @State private var allergies: [String] = []
    
    let genders = ["Laki-laki", "Perempuan"]
    
    // Allergen Selection
    @State private var showAllergenSheet = false
    let commonAllergens = [
        "Susu Sapi", "Telur", "Kacang Tanah", "Kacang Pohon",
        "Kedelai", "Gandum", "Ikan", "Kerang/Seafood"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.creamWhite.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        nameInput
                        dobInput
                        genderInput
                        allergySection
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Edit Profil Bayi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Batal") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textMidGray)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Simpan") {
                        viewModel.updateBaby(
                            name: name,
                            dateOfBirth: dateOfBirth,
                            gender: gender,
                            allergies: allergies
                        )
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.orangeMain)
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if let baby = viewModel.currentBaby {
                    name = baby.name
                    dateOfBirth = baby.dateOfBirth
                    gender = baby.gender
                    allergies = baby.allergies
                }
            }
        }
    }
    
    // MARK: - Name Input
    private var nameInput: some View {
        inputSection(title: "Nama Bayi", icon: "person.fill") {
            TextField("Masukkan nama si kecil", text: $name)
                .font(AppFonts.bodyRegular())
                .foregroundColor(AppColors.inputText)
                .padding(14)
                .background(AppColors.inputBackground)
                .cornerRadius(12)
        }
    }
    
    // MARK: - Date of Birth
    private var dobInput: some View {
        inputSection(title: "Tanggal Lahir", icon: "calendar") {
            HStack {
                Text(dateOfBirth.formatted(date: .long, time: .omitted))
                    .font(.body)
                    .foregroundColor(AppColors.orangeMain)
                Spacer()
                Image(systemName: "calendar")
                    .foregroundColor(AppColors.orangeMain)
                    .font(.body)
            }
            .padding(14)
            .background(AppColors.inputBackground)
            .cornerRadius(12)
            .overlay {
                DatePicker("", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(AppColors.orangeMain)
                    .opacity(0.011)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
        }
    }
    
    // MARK: - Gender
    private var genderInput: some View {
        inputSection(title: "Jenis Kelamin", icon: "figure.and.child.halved.filled") {
            HStack(spacing: 12) {
                ForEach(genders, id: \.self) { g in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) { gender = g }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: g == "Laki-laki" ? "figure.stand" : "figure.stand.dress")
                                .font(.system(size: 16))
                            Text(g)
                                .font(AppFonts.bodyRegular())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(gender == g ? AppColors.orangeTint : AppColors.inputBackground)
                        .foregroundColor(gender == g ? AppColors.orangeMain : AppColors.textMidGray)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(gender == g ? AppColors.orangeMain : Color.clear, lineWidth: 1.5)
                        )
                    }
                }
            }
        }
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
            
            Button(action: {
                showAllergenSheet = true
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
            
            if !allergies.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(allergies.sorted(), id: \.self) { allergen in
                            HStack(spacing: 4) {
                                Text(allergen)
                                    .font(AppFonts.caption())
                                    .foregroundColor(AppColors.alertRed)
                                    
                                Button(action: {
                                    if let index = allergies.firstIndex(of: allergen) {
                                        allergies.remove(at: index)
                                    }
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
        .sheet(isPresented: $showAllergenSheet) {
            EditAllergenSelectionSheet(
                selectedAllergies: $allergies,
                commonAllergens: commonAllergens
            )
            .presentationDetents([.medium, .large])
        }
    }
    
    // MARK: - Reusable Components
    private func inputSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
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
}

// MARK: - Allergen Selection Sheet for Edit
struct EditAllergenSelectionSheet: View {
    @Binding var selectedAllergies: [String]
    let commonAllergens: [String]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(commonAllergens, id: \.self) { allergen in
                    Button(action: {
                        if selectedAllergies.contains(allergen) {
                            selectedAllergies.removeAll(where: { $0 == allergen })
                        } else {
                            selectedAllergies.append(allergen)
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        HStack {
                            Text(allergen)
                                .font(AppFonts.bodyRegular())
                                .foregroundColor(AppColors.textDark)
                            Spacer()
                            if selectedAllergies.contains(allergen) {
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

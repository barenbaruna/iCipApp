//
//  InputMeasurementSheet.swift
//  iCipApp
//
//  Sheet to input new weight and height measurements.
//

import SwiftUI

// MARK: - Input Measurement Sheet
struct InputMeasurementSheet: View {
    
    @ObservedObject var viewModel: RiwayatViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDatePicker = false
    @FocusState private var focusedField: Field?
    
    private enum Field { case weight, height }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Text("Input Data Pertumbuhan")
                        .font(AppFonts.heading2())
                        .foregroundColor(AppColors.textDark)
                    
                    Text("Catat berat dan tinggi badan si kecil")
                        .font(AppFonts.caption())
                        .foregroundColor(AppColors.textMidGray)
                
                // Input fields
                VStack(spacing: 16) {
                    // Date picker
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.orangeMain)
                            Text("Tanggal Pengukuran")
                                .font(AppFonts.caption())
                                .foregroundColor(AppColors.textMidGray)
                        }
                        
                        Button(action: {
                            showDatePicker = true
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }) {
                            HStack {
                                Text(viewModel.selectedDate.formatted(date: .long, time: .omitted))
                                    .font(AppFonts.bodyRegular())
                                    .foregroundColor(AppColors.orangeMain)
                                Spacer()
                                Image(systemName: "calendar")
                                    .foregroundColor(AppColors.orangeMain)
                                    .font(.body)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .background(AppColors.inputBackground)
                            .cornerRadius(12)
                        }
                    }
                    
                    inputField(
                        icon: "scalemass.fill",
                        label: "Berat Badan",
                        placeholder: "Contoh: 7.5",
                        unit: "kg",
                        text: $viewModel.inputWeight,
                        color: AppColors.greenMain
                    )
                    
                    inputField(
                        icon: "ruler.fill",
                        label: "Tinggi Badan",
                        placeholder: "Contoh: 68.0",
                        unit: "cm",
                        text: $viewModel.inputHeight,
                        color: AppColors.infoBlue
                    )
                }
                
                // Invisible anchor for scrolling to bottom
                Color.clear.frame(height: 1).id("bottom")
            }
            .padding(24)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedField = .weight
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: UnitPoint.bottom)
                    }
                }
            }
            } // End ScrollView
            } // End ScrollViewReader
            .safeAreaInset(edge: .bottom) {
                // Save button pinned to bottom
                Button(action: {
                    viewModel.addMeasurement()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Simpan")
                            .font(AppFonts.ctaText())
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        (viewModel.inputWeight.isEmpty || viewModel.inputHeight.isEmpty)
                            ? AnyShapeStyle(Color.gray.opacity(0.4))
                            : AnyShapeStyle(AppColors.primaryGradient)
                    )
                    .cornerRadius(14)
                }
                .disabled(viewModel.inputWeight.isEmpty || viewModel.inputHeight.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
                .background(AppColors.creamWhite)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(AppColors.creamWhite.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textSubtleGray)
                            .font(.system(size: 22))
                    }
                }
            }
            .sheet(isPresented: $showDatePicker) {
                VStack(spacing: 0) {
                    HStack {
                        Text("Tanggal Pengukuran")
                            .font(AppFonts.heading2())
                            .foregroundColor(AppColors.textDark)
                        Spacer()
                        Button("Selesai") {
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
                        selection: $viewModel.selectedDate,
                        in: (viewModel.currentBaby?.dateOfBirth ?? Date())...Date(),
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
    }
    
    // MARK: - Input Field
    private func inputField(icon: String, label: String, placeholder: String, unit: String, text: Binding<String>, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Text(label)
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.textMidGray)
            }
            
            HStack {
                TextField(placeholder, text: text)
                    .keyboardType(.decimalPad)
                    .font(AppFonts.bodyRegular())
                    .foregroundColor(AppColors.inputText)
                    .focused($focusedField, equals: label == "Berat Badan" ? .weight : (label == "Tinggi Badan" ? .height : nil))
                
                Text(unit)
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.textSubtleGray)
            }
            .padding(14)
            .background(AppColors.inputBackground)
            .cornerRadius(12)
        }
    }
}

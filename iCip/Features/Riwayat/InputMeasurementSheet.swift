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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header illustration
                ZStack {
                    Circle()
                        .fill(AppColors.orangeTint)
                        .frame(width: 80, height: 80)
                    Image(systemName: "scalemass.fill")
                        .font(.system(size: 34))
                        .foregroundColor(AppColors.orangeMain)
                }
                .padding(.top, 12)
                
                Text("Input Data Pertumbuhan")
                    .font(AppFonts.heading2())
                    .foregroundColor(AppColors.textDark)
                
                Text("Catat berat dan tinggi badan si kecil hari ini")
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.textMidGray)
                
                // Date display
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(AppColors.orangeMain)
                    Text(Date().formatted(.dateTime.day().month(.wide).year()))
                        .font(AppFonts.bodyRegular())
                        .foregroundColor(AppColors.textDark)
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(AppColors.surfaceGray)
                .cornerRadius(12)
                
                // Input fields
                VStack(spacing: 16) {
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
                
                Spacer()
                
                // Save button
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
            }
            .padding(24)
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

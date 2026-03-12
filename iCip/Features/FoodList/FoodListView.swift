//
//  FoodListView.swift
//  iCipApp
//
//  Eksplorasi Tab — Grid view with search and age-based filtering.
//  Apple HIG: Keyboard dismissal, safe area, haptic feedback
//

import SwiftData
import SwiftUI

// MARK: - Food List View
struct FoodListView: View {

    // MARK: - Properties
    @StateObject private var viewModel = FoodListViewModel()
    @State private var animateGrid = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    filterChips

                    if viewModel.filteredRecipes.isEmpty {
                        emptyState
                    } else {
                        recipeGrid
                    }
                }
            }
            .background(AppColors.creamWhite.ignoresSafeArea())
            .navigationTitle("Eksplorasi")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "Cari resep MPASI...")
            .onAppear {
                viewModel.loadRecipes()
                withAnimation(.easeOut(duration: 0.4).delay(0.2)) { animateGrid = true }
            }
        }
    }

    // MARK: - Filter Chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.ageFilters, id: \.self) { filter in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.selectedAgeFilter = filter
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        Text(filter)
                            .font(AppFonts.caption())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedAgeFilter == filter
                                    ? AppColors.orangeMain : AppColors.surfaceGray
                            )
                            .foregroundColor(
                                viewModel.selectedAgeFilter == filter
                                    ? .white : AppColors.textMidGray
                            )
                            .cornerRadius(20)
                            .scaleEffect(viewModel.selectedAgeFilter == filter ? 1.05 : 1.0)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Recipe Grid
    private var recipeGrid: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14),
                ],
                spacing: 14
            ) {
                ForEach(Array(viewModel.filteredRecipes.enumerated()), id: \.element.id) {
                    index, recipe in
                    NavigationLink(destination: FoodDetailView(recipe: recipe, conflicts: [])) {
                        foodGridCard(recipe: recipe)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .opacity(animateGrid ? 1 : 0)
                    .offset(y: animateGrid ? 0 : 20)
                    .animation(
                        .easeOut(duration: 0.4).delay(Double(index) * 0.05), value: animateGrid)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Grid Card
    private func foodGridCard(recipe: RecipeItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            FoodImage(imageUrl: recipe.id, ageMinimumMonths: recipe.ageMinimumMonths, height: 90)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 14, bottomLeadingRadius: 0, bottomTrailingRadius: 0,
                        topTrailingRadius: 14))

            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textDark)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 9))
                        .foregroundColor(AppColors.orangeMain)
                    Text("\(Int(recipe.calories)) kkal")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textMidGray)
                }
            }
            .padding(10)
        }
        .background(AppColors.cardWhite)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(AppColors.textSubtleGray)
            Text("Tidak ditemukan resep yang cocok")
                .font(AppFonts.bodyRegular())
                .foregroundColor(AppColors.textMidGray)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .transition(.opacity)
    }

    // MARK: - Helpers
    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

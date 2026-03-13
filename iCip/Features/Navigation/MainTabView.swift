//
//  MainTabView.swift
//  iCipApp
//
//  Main Tab Navigation — 3 tabs per PRD.
//

import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    
    // MARK: - Properties
    @State private var selectedTab = 0
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Beranda", systemImage: "house.fill")
                }
                .tag(0)
            
            FoodListView()
                .tabItem {
                    Label("Menu", systemImage: "fork.knife")
                }
                .tag(1)
            
            RiwayatView()
                .tabItem {
                    Label("Riwayat", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.crop.circle.fill")
                }
                .tag(3)
        }
        .tint(AppColors.orangeMain)
    }
}

//
//  FoodImage.swift
//  iCipApp
//
//  Created by Jordan Anderson on 11/03/26.
//

import SwiftUI

struct FoodImage: View {
    let imageUrl: String?
    let ageMinimumMonths: Int
    var height: CGFloat = 120

    var body: some View {
        if let name = imageUrl, UIImage(named: name) != nil {
            Image(name)
                .resizable()
                .scaledToFill()
                .frame(height: height)
                .clipped()
        } else {
            PlaceholderFoodImage(ageMinimumMonths: ageMinimumMonths, height: height)
        }
    }
}

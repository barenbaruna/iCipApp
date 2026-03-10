//
//  Item.swift
//  iCipApp
//
//  Created by Baren Baruna Harahap on 10/03/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

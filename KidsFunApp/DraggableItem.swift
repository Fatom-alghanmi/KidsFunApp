//
//  DraggableItem.swift
//  KidsFunApp
//
//  Created by Fatom on 2025-11-05.
//

import SwiftUI

struct DraggableItem: Identifiable {
    let id = UUID()          // Unique ID automatically
    let name: String         // Name of the image
    var position: CGPoint    // Initial position

    // Custom initializer
    init(name: String, position: CGPoint) {
        self.name = name
        self.position = position
    }
}

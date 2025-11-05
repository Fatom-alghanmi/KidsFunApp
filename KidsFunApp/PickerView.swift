//
//  PickerView.swift
//  KidsFunApp
//
//  Created by Fatom on 2025-11-05.
//

import SwiftUI

struct PickerView: View {
    let category: String
    @State private var selectedItem: String? = nil
    
    var items: [String] {
        if category == "Animals" {
            return ["lion", "cat", "dog"]  // animal names
        } else {
            return ["Letter Game"]         // start letter game
        }
    }

    var body: some View {
        VStack(spacing: 30) {
            Text("Pick a \(category.dropLast())!")
                .font(.title)
                .fontWeight(.bold)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 30) {
                    ForEach(items, id: \.self) { item in
                        Button {
                            selectedItem = item
                        } label: {
                            VStack {
                                Image(item)  // For letter game, you can show a fun icon
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(20)
                                    .shadow(radius: selectedItem == item ? 10 : 0)
                                    .scaleEffect(selectedItem == item ? 1.1 : 1.0)
                                    .animation(.easeInOut, value: selectedItem)
                                Text(item)
                                    .font(.headline)
                            }
                        }
                    }
                }
                .padding()
            }

            if let selected = selectedItem {
                NavigationLink {
                    // Navigate based on category
                    if category == "Animals" {
                        ActivityView(correctItem: selected)  // your existing animal game
                    } else {
                        LetterGameView()                      // start the new letter game
                    }
                } label: {
                    Text(category == "Animals" ? "Start Fun with \(selected.capitalized)" : "Start Letter Game")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(20)
                }
            }

            Spacer()
        }
        .padding()
    }
}

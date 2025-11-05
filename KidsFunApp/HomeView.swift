//
//  HomeView.swift
//  KidsFunApp
//
//  Created by Fatom on 2025-11-05.
//

import SwiftUI
import AVKit
import AVFoundation

// MARK: - HomeView with Component Picker
struct HomeView: View {
    @State private var selectedCategory = "Animals"
    let categories = ["Animals", "Letters"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("🎉 Welcome to Kids Fun App! 🎉")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Picker("Select Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                NavigationLink {
                    if selectedCategory == "Animals" {
                        ActivityView(correctItem: "lion") // Start animal game
                    } else {
                        LetterGameView() // Start letter game
                    }
                } label: {
                    Text("Start Game")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
        }
    }
}

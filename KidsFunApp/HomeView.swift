//
//  HomeView.swift
//  KidsFunApp
//
//  Created by Fatom on 2025-11-05.
//

import SwiftUI

struct HomeView: View {
    let categories = ["Animals", "Letters"]

    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Text("🎉 Welcome to Learning Fun! 🎉")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()

                ForEach(categories, id: \.self) { category in
                    NavigationLink {
                        PickerView(category: category)
                    } label: {
                        Text(category)
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(20)
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}


#Preview {
    HomeView()
}

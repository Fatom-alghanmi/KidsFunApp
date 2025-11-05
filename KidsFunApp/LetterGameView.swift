//
//  LetterGameView.swift
//  KidsFunApp
//
//  Created by Fatom on 2025-11-05.
//

import SwiftUI
import AVKit
import AVFoundation

struct LetterGameView: View {
    @Environment(\.dismiss) var dismiss
    
    // Letter sequence for the game
    let letters: [String] = ["A","B","C","D","E"]
    
    // Map letters to correct images
    let letterImageMap: [String:String] = [
        "A":"apple",
        "B":"ball",
        "C":"cat",
        "D":"dog",
        "E":"elephant"
    ]
    
    // Distractor images
    let allImages = ["apple","ball","cat","dog","elephant","fish","monkey"]
    
    // Game state
    @State private var currentIndex = 0
    @State private var items: [DraggableItem] = []
    
    // Audio players
    @State private var backgroundPlayer: AVAudioPlayer?
    @State private var successPlayer: AVAudioPlayer?
    
    // Target
    let targetFrame = CGRect(x: 200, y: 400, width: 150, height: 150)
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Drag the image for letter \(letters[currentIndex]) to the Target 🟧")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                Rectangle()
                    .strokeBorder(Color.orange, lineWidth: 4)
                    .frame(width: targetFrame.width, height: targetFrame.height)
                    .overlay(Text("Target").font(.headline).foregroundColor(.orange))
                    .position(x: targetFrame.midX, y: targetFrame.midY)
                
                Spacer()
            }
            
            // Draggable items
            ForEach(items) { item in
                DraggableView(item: item,
                              targetFrame: targetFrame,
                              correctItemName: letterImageMap[letters[currentIndex]]!) {
                    // Correct drag
                    playSuccessSound()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        playCelebrationVideo()
                    }
                }
            }
        }
        .onAppear {
            setupItems()
            playBackgroundMusic()
        }
        .onDisappear {
            // Stop background music immediately
            backgroundPlayer?.stop()
        }
    }
    
    // MARK: - Setup draggable items
    func setupItems() {
        let correct = letterImageMap[letters[currentIndex]]!
        let wrongImages = allImages.filter { $0 != correct }.shuffled()
        items = [
            DraggableItem(name: correct, position: CGPoint(x: 50, y: 650)),
            DraggableItem(name: wrongImages[0], position: CGPoint(x: 150, y: 650)),
            DraggableItem(name: wrongImages[1], position: CGPoint(x: 250, y: 650))
        ].shuffled() // randomize positions
    }
    
    // MARK: - Audio
    func playBackgroundMusic() {
        if let url = Bundle.main.url(forResource: "background", withExtension: "mp3") {
            do {
                backgroundPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundPlayer?.numberOfLoops = -1
                backgroundPlayer?.volume = 0.3
                backgroundPlayer?.play()
            } catch { print("Background music error: \(error.localizedDescription)") }
        }
    }
    
    func playSuccessSound() {
        if let url = Bundle.main.url(forResource: "success", withExtension: "mp3") {
            do {
                successPlayer = try AVAudioPlayer(contentsOf: url)
                successPlayer?.play()
            } catch { print("Success sound error: \(error.localizedDescription)") }
        }
    }
    
    // MARK: - Celebration video
    func playCelebrationVideo() {
        guard let url = Bundle.main.url(forResource: "celebration", withExtension: "mp4") else { return }
        
        // Stop background music temporarily
        backgroundPlayer?.stop()
        
        let player = AVPlayer(url: url)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        playerVC.showsPlaybackControls = false
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            rootVC.present(playerVC, animated: true) {
                player.play()
            }
            
            // Detect end of video
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                   object: player.currentItem, queue: .main) { _ in
                playerVC.dismiss(animated: true) {
                    nextLetterOrEnd()
                }
            }
        }
    }
    
    // MARK: - Move to next letter
    func nextLetterOrEnd() {
        if currentIndex + 1 < letters.count {
            currentIndex += 1
            setupItems()
            backgroundPlayer?.play() // resume background music
        } else {
            // Finished all letters, return to main
            dismiss()
        }
    }
}


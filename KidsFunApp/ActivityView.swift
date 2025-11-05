//
//  ActivityView.swift
//  KidsFunApp
//
//  Created by Fatom on 2025-11-05.
//

import SwiftUI
import AVKit
import AVFoundation

struct ActivityView: View {
    @Environment(\.dismiss) var dismiss
    
    let correctItem: String   // from PickerView
    
    @State private var items: [DraggableItem] = []
    @State private var backgroundPlayer: AVAudioPlayer?
    @State private var successPlayer: AVAudioPlayer?
    
    let targetFrame = CGRect(x: 200, y: 400, width: 150, height: 150)
    
    // Letter-to-image mapping for letters game
    let letterImageMap: [String: String] = [
        "A": "apple",
        "B": "ball"
    ]
    
    var correctImage: String {
        // If correctItem is a letter, map to image
        if let image = letterImageMap[correctItem.uppercased()] {
            return image
        }
        return correctItem // For animals, already image name
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Drag the image for \(correctItem.uppercased()) to the Target 🟧")
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
            
            ForEach(items) { item in
                DraggableView(item: item, targetFrame: targetFrame, correctItemName: correctImage) {
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
            backgroundPlayer?.stop()
            backgroundPlayer = nil
        }
    }
    
    // MARK: - Setup draggable items
    func setupItems() {
        let correct = correctImage
        let allImages = ["apple","ball","lion","cat"]
        let wrongImages = allImages.filter { $0 != correct }.shuffled()
        
        items = [
            DraggableItem(name: correct, position: CGPoint(x: 50, y: 650)),
            DraggableItem(name: wrongImages[0], position: CGPoint(x: 150, y: 650)),
            DraggableItem(name: wrongImages[1], position: CGPoint(x: 250, y: 650))
        ]
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
        
        // Stop background music
        backgroundPlayer?.stop()
        
        let player = AVPlayer(url: url)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        playerVC.showsPlaybackControls = false
        
        // Present video
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            rootVC.present(playerVC, animated: true) {
                player.play() // auto-play
            }
            
            // Observe video completion
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                   object: player.currentItem, queue: .main) { _ in
                playerVC.dismiss(animated: true) {
                    dismiss() // go back to PickerView
                }
            }
        }
    }
}

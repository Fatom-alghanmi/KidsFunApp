//
//  LetterGameView.swift
//  KidsFunApp
//
//  Created by Fatom on 2025-11-05.
//

import SwiftUI
import AVKit
import AVFoundation

// MARK: - LetterGameView (Letters)
struct LetterGameView: View {
    @Environment(\.dismiss) var dismiss
    
    let letters: [String] = ["A","B","C","D","E"]
    let letterImageMap: [String:String] = [
        "A":"apple",
        "B":"ball",
        "C":"cat",
        "D":"dog",
        "E":"elephant"
    ]
    let allImages = ["apple","ball","cat","dog","elephant","fish","monkey"]
    
    @State private var currentIndex = 0
    @State private var items: [DraggableItem] = []
    @State private var backgroundPlayer: AVAudioPlayer?
    @State private var successPlayer: AVAudioPlayer?
    
    let targetFrame = CGRect(x: 200, y: 400, width: 150, height: 150)
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.1).ignoresSafeArea() // Fun background
            
            VStack(spacing: 20) {
                Text("Drag the image for letter \(letters[currentIndex]) to the Target 🟧")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                Rectangle()
                    .fill(Color.purple.opacity(0.3))
                    .frame(width: targetFrame.width, height: targetFrame.height)
                    .overlay(
                        Rectangle()
                            .strokeBorder(Color.purple, lineWidth: 4)
                            .overlay(Text("Target").foregroundColor(.purple).fontWeight(.bold))
                    )
                    .position(x: targetFrame.midX, y: targetFrame.midY)
                
                Spacer()
            }
            
            ForEach(items) { item in
                DraggableView(item: item,
                              targetFrame: targetFrame,
                              correctItemName: letterImageMap[letters[currentIndex]]!) {
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
        }
    }
    
    func setupItems() {
        let correct = letterImageMap[letters[currentIndex]]!
        let wrongImages = allImages.filter { $0 != correct }.shuffled()
        items = [
            DraggableItem(name: correct, position: CGPoint(x: 50, y: 650)),
            DraggableItem(name: wrongImages[0], position: CGPoint(x: 150, y: 650)),
            DraggableItem(name: wrongImages[1], position: CGPoint(x: 250, y: 650))
        ].shuffled()
    }
    
    func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "background", withExtension: "mp3") else { return }
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = -1
            backgroundPlayer?.volume = 0.3
            backgroundPlayer?.play()
        } catch { print(error.localizedDescription) }
    }
    
    func playSuccessSound() {
        guard let url = Bundle.main.url(forResource: "success", withExtension: "mp3") else { return }
        do {
            successPlayer = try AVAudioPlayer(contentsOf: url)
            successPlayer?.play()
        } catch { print(error.localizedDescription) }
    }
    
    func playCelebrationVideo() {
        guard let url = Bundle.main.url(forResource: "celebration", withExtension: "mp4") else { return }
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
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                   object: player.currentItem, queue: .main) { _ in
                playerVC.dismiss(animated: true) {
                    nextLetterOrEnd()
                }
            }
        }
    }
    
    func nextLetterOrEnd() {
        if currentIndex + 1 < letters.count {
            currentIndex += 1
            setupItems()
            backgroundPlayer?.play()
        } else {
            dismiss()
        }
    }
}

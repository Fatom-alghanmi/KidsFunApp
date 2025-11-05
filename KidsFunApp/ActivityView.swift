import SwiftUI
import AVKit
import AVFoundation

struct ActivityView: View {
    @Environment(\.dismiss) var dismiss
    let correctItem: String
    
    @State private var items: [DraggableItem] = []
    @State private var backgroundPlayer: AVAudioPlayer?
    @State private var successPlayer: AVAudioPlayer?
    
    let targetFrame = CGRect(x: 200, y: 400, width: 150, height: 150)
    
    var body: some View {
        ZStack {
            Color.green.opacity(0.1).ignoresSafeArea() // Fun background
            
            VStack(spacing: 20) {
                Text("Drag the image for \(correctItem.uppercased()) to the Target 🟧")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                // Colored target
                Rectangle()
                    .fill(Color.orange.opacity(0.3))
                    .frame(width: targetFrame.width, height: targetFrame.height)
                    .overlay(
                        Rectangle()
                            .strokeBorder(Color.orange, lineWidth: 4)
                            .overlay(Text("Target").foregroundColor(.orange).fontWeight(.bold))
                    )
                    .position(x: targetFrame.midX, y: targetFrame.midY)
                
                Spacer()
            }
            
            // Draggable items
            ForEach(items) { item in
                DraggableView(item: item,
                              targetFrame: targetFrame,
                              correctItemName: correctItem) {
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
    
    func setupItems() {
        let allImages = ["lion","cat","dog","elephant"]
        let wrongImages = allImages.filter { $0 != correctItem }.shuffled()
        
        items = [
            DraggableItem(name: correctItem, position: CGPoint(x: 50, y: 650)),
            DraggableItem(name: wrongImages[0], position: CGPoint(x: 150, y: 650)),
            DraggableItem(name: wrongImages[1], position: CGPoint(x: 250, y: 650))
        ]
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
                    dismiss()
                }
            }
        }
    }
}

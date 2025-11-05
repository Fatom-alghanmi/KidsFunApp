import SwiftUI

struct DraggableView: View {
    @State var item: DraggableItem
    var targetFrame: CGRect
    var correctItemName: String
    var onSuccess: () -> Void
    
    @State private var offset = CGSize.zero
    @State private var dropped = false
    
    var body: some View {
        Image(item.name)
            .resizable()
            .scaledToFill()
            .frame(width: dropped ? targetFrame.width : 100,
                   height: dropped ? targetFrame.height : 100)
            .clipped()
            .cornerRadius(dropped ? 0 : 12)
            .position(dropped
                        ? CGPoint(x: targetFrame.midX, y: targetFrame.midY)
                        : CGPoint(x: item.position.x + offset.width,
                                  y: item.position.y + offset.height)
            )
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { gesture in
                        let finalPos = CGPoint(x: item.position.x + gesture.translation.width,
                                               y: item.position.y + gesture.translation.height)
                        if targetFrame.contains(finalPos) && !dropped {
                            if item.name == correctItemName {
                                dropped = true
                                offset = .zero
                                onSuccess()
                            } else {
                                offset = .zero
                            }
                        } else {
                            offset = .zero
                        }
                    }
            )
            .animation(.spring(), value: offset)
    }
}

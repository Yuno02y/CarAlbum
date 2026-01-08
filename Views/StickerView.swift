import SwiftUI

struct StickerView: View {
    @EnvironmentObject private var store: BoardStore

    @ObservedObject var sticker: StickerEntity
    let isSelected: Bool
    let onSelect: () -> Void

    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var magnifyBy: CGFloat = 1
    @GestureState private var rotateBy: Angle = .zero

    var body: some View {
        let image = ImageStore.shared.loadImage(fileName: sticker.imageFileName)
        let content = Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .padding(24)
            }
        }

        content
            .brightness(sticker.brightness)
            .shadow(color: sticker.shadowEnabled ? .black.opacity(0.35) : .clear, radius: 8, x: 0, y: 6)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(sticker.outlineEnabled ? Color.white.opacity(0.85) : .clear, lineWidth: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 2)
            )
            .overlay(alignment: .bottomLeading) {
                if let caption = sticker.caption, !caption.isEmpty {
                    Text(caption)
                        .font(.caption2.bold())
                        .padding(6)
                        .background(.black.opacity(0.4))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(6)
                }
            }
            .scaleEffect(sticker.scale * magnifyBy)
            .rotationEffect(Angle(radians: sticker.rotation) + rotateBy)
            .offset(
                x: sticker.positionX + dragOffset.width,
                y: sticker.positionY + dragOffset.height
            )
            .onTapGesture {
                onSelect()
            }
            .gesture(dragGesture)
            .gesture(magnificationGesture)
            .gesture(rotationGesture)
            .contextMenu {
                Button {
                    store.bringForward(sticker, in: sticker.board)
                } label: {
                    Label("前面へ", systemImage: "arrow.up.square")
                }
                Button {
                    store.sendBackward(sticker)
                } label: {
                    Label("背面へ", systemImage: "arrow.down.square")
                }
                Button {
                    store.duplicate(sticker, in: sticker.board)
                } label: {
                    Label("複製", systemImage: "plus.square.on.square")
                }
                Button(role: .destructive) {
                    store.removeSticker(sticker)
                } label: {
                    Label("削除", systemImage: "trash")
                }
            }
            .zIndex(Double(sticker.zIndex))
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                sticker.position = CGPoint(
                    x: sticker.positionX + value.translation.width,
                    y: sticker.positionY + value.translation.height
                )
                store.save()
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .updating($magnifyBy) { value, state, _ in
                state = value
            }
            .onEnded { value in
                sticker.scale *= value
                store.save()
            }
    }

    private var rotationGesture: some Gesture {
        RotationGesture()
            .updating($rotateBy) { value, state, _ in
                state = value
            }
            .onEnded { value in
                sticker.rotation += value.radians
                store.save()
            }
    }
}

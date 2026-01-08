import SwiftUI
import CoreData

struct BoardCanvasView: View {
    let board: BoardEntity
    let canvasSize: CGSize
    let selectedStickerID: NSManagedObjectID?
    let onSelect: (StickerEntity) -> Void

    var body: some View {
        ZStack {
            BackgroundStyle(rawValue: board.backgroundStyle)?.view() ?? Color(.systemBackground)
            if let templateId = board.templateId {
                TemplateOverlay(template: TemplateLibrary.template(for: templateId))
            }
            ForEach(board.sortedStickers) { sticker in
                StickerView(sticker: sticker, isSelected: sticker.objectID == selectedStickerID) {
                    onSelect(sticker)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
        )
        .frame(width: canvasSize.width, height: canvasSize.height)
    }
}

private struct TemplateOverlay: View {
    let template: BoardTemplate

    var body: some View {
        GeometryReader { proxy in
            ForEach(Array(template.slots.enumerated()), id: \.offset) { _, slot in
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: slot.width * proxy.size.width, height: slot.height * proxy.size.height)
                    .position(
                        x: slot.midX * proxy.size.width,
                        y: slot.midY * proxy.size.height
                    )
            }
            if template.showsTitleArea {
                Text("CAR ALBUM")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.6))
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.1)
            }
        }
    }
}

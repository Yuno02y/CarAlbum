import Foundation
import CoreData
import SwiftUI

final class BoardStore: ObservableObject {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func createBoard(template: BoardTemplate) -> BoardEntity {
        let board = BoardEntity(context: context)
        board.id = UUID()
        board.title = BoardEntity.defaultTitle
        board.createdAt = Date()
        board.updatedAt = Date()
        board.templateId = template.id == TemplateLibrary.free.id ? nil : template.id
        board.backgroundStyle = BackgroundStyle.classic.rawValue
        save()
        return board
    }

    func delete(board: BoardEntity) {
        context.delete(board)
        save()
    }

    func addSticker(to board: BoardEntity, image: UIImage, initialRect: CGRect?, canvasSize: CGSize) {
        guard let fileName = ImageStore.shared.save(image: image) else { return }
        let sticker = StickerEntity(context: context)
        sticker.id = UUID()
        sticker.boardId = board.id
        sticker.imageFileName = fileName
        sticker.scale = 1
        sticker.rotation = 0
        sticker.zIndex = Int16(board.stickers.count)
        sticker.shadowEnabled = true
        sticker.outlineEnabled = false
        sticker.brightness = 0
        sticker.cutoutApplied = false
        sticker.caption = nil
        sticker.createdAt = Date()
        sticker.board = board

        if let rect = initialRect {
            let x = (rect.midX * canvasSize.width) - canvasSize.width / 2
            let y = (rect.midY * canvasSize.height) - canvasSize.height / 2
            sticker.position = CGPoint(x: x, y: y)
            let scaleX = rect.width * canvasSize.width / max(image.size.width, 1)
            let scaleY = rect.height * canvasSize.height / max(image.size.height, 1)
            sticker.scale = min(scaleX, scaleY)
        } else {
            sticker.position = .zero
        }

        board.updatedAt = Date()
        save()
    }

    func update(board: BoardEntity) {
        board.updatedAt = Date()
        save()
    }

    func removeSticker(_ sticker: StickerEntity) {
        context.delete(sticker)
        save()
    }

    func bringForward(_ sticker: StickerEntity, in board: BoardEntity) {
        let maxIndex = board.stickers.map { Int($0.zIndex) }.max() ?? 0
        sticker.zIndex = Int16(maxIndex + 1)
        save()
    }

    func sendBackward(_ sticker: StickerEntity) {
        sticker.zIndex = max(0, sticker.zIndex - 1)
        save()
    }

    func duplicate(_ sticker: StickerEntity, in board: BoardEntity) {
        guard let image = ImageStore.shared.loadImage(fileName: sticker.imageFileName) else { return }
        let newSticker = StickerEntity(context: context)
        newSticker.id = UUID()
        newSticker.boardId = board.id
        newSticker.imageFileName = ImageStore.shared.save(image: image) ?? sticker.imageFileName
        newSticker.position = CGPoint(x: sticker.positionX + 12, y: sticker.positionY + 12)
        newSticker.scale = sticker.scale
        newSticker.rotation = sticker.rotation
        newSticker.zIndex = Int16(board.stickers.count + 1)
        newSticker.shadowEnabled = sticker.shadowEnabled
        newSticker.outlineEnabled = sticker.outlineEnabled
        newSticker.brightness = sticker.brightness
        newSticker.cutoutApplied = sticker.cutoutApplied
        newSticker.caption = sticker.caption
        newSticker.createdAt = Date()
        newSticker.board = board
        save()
    }

    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                assertionFailure("Failed to save CoreData: \(error)")
            }
        }
    }
}

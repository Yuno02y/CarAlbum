import Foundation
import CoreData

@objc(BoardEntity)
public final class BoardEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BoardEntity> {
        NSFetchRequest<BoardEntity>(entityName: "BoardEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var templateId: String?
    @NSManaged public var backgroundStyle: String
    @NSManaged public var stickers: Set<StickerEntity>
}

extension BoardEntity {
    static let defaultTitle = "My Car Board"

    var sortedStickers: [StickerEntity] {
        stickers.sorted { $0.zIndex < $1.zIndex }
    }
}

import Foundation
import CoreData

@objc(StickerEntity)
public final class StickerEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StickerEntity> {
        NSFetchRequest<StickerEntity>(entityName: "StickerEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var boardId: UUID
    @NSManaged public var imageFileName: String
    @NSManaged public var positionX: Double
    @NSManaged public var positionY: Double
    @NSManaged public var scale: Double
    @NSManaged public var rotation: Double
    @NSManaged public var zIndex: Int16
    @NSManaged public var shadowEnabled: Bool
    @NSManaged public var outlineEnabled: Bool
    @NSManaged public var brightness: Double
    @NSManaged public var cutoutApplied: Bool
    @NSManaged public var caption: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var board: BoardEntity
}

extension StickerEntity {
    var position: CGPoint {
        get { CGPoint(x: positionX, y: positionY) }
        set {
            positionX = newValue.x
            positionY = newValue.y
        }
    }
}

import Foundation
import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let model = NSManagedObjectModel()

        let boardEntity = NSEntityDescription()
        boardEntity.name = "BoardEntity"
        boardEntity.managedObjectClassName = NSStringFromClass(BoardEntity.self)

        let stickerEntity = NSEntityDescription()
        stickerEntity.name = "StickerEntity"
        stickerEntity.managedObjectClassName = NSStringFromClass(StickerEntity.self)

        let boardId = NSAttributeDescription()
        boardId.name = "id"
        boardId.attributeType = .UUIDAttributeType
        boardId.isOptional = false

        let boardTitle = NSAttributeDescription()
        boardTitle.name = "title"
        boardTitle.attributeType = .stringAttributeType
        boardTitle.isOptional = false

        let createdAt = NSAttributeDescription()
        createdAt.name = "createdAt"
        createdAt.attributeType = .dateAttributeType
        createdAt.isOptional = false

        let updatedAt = NSAttributeDescription()
        updatedAt.name = "updatedAt"
        updatedAt.attributeType = .dateAttributeType
        updatedAt.isOptional = false

        let templateId = NSAttributeDescription()
        templateId.name = "templateId"
        templateId.attributeType = .stringAttributeType
        templateId.isOptional = true

        let backgroundStyle = NSAttributeDescription()
        backgroundStyle.name = "backgroundStyle"
        backgroundStyle.attributeType = .stringAttributeType
        backgroundStyle.isOptional = false

        boardEntity.properties = [boardId, boardTitle, createdAt, updatedAt, templateId, backgroundStyle]

        let stickerId = NSAttributeDescription()
        stickerId.name = "id"
        stickerId.attributeType = .UUIDAttributeType
        stickerId.isOptional = false

        let stickerBoardId = NSAttributeDescription()
        stickerBoardId.name = "boardId"
        stickerBoardId.attributeType = .UUIDAttributeType
        stickerBoardId.isOptional = false

        let imageFileName = NSAttributeDescription()
        imageFileName.name = "imageFileName"
        imageFileName.attributeType = .stringAttributeType
        imageFileName.isOptional = false

        let positionX = NSAttributeDescription()
        positionX.name = "positionX"
        positionX.attributeType = .doubleAttributeType
        positionX.isOptional = false
        positionX.defaultValue = 0

        let positionY = NSAttributeDescription()
        positionY.name = "positionY"
        positionY.attributeType = .doubleAttributeType
        positionY.isOptional = false
        positionY.defaultValue = 0

        let scale = NSAttributeDescription()
        scale.name = "scale"
        scale.attributeType = .doubleAttributeType
        scale.isOptional = false
        scale.defaultValue = 1

        let rotation = NSAttributeDescription()
        rotation.name = "rotation"
        rotation.attributeType = .doubleAttributeType
        rotation.isOptional = false
        rotation.defaultValue = 0

        let zIndex = NSAttributeDescription()
        zIndex.name = "zIndex"
        zIndex.attributeType = .integer16AttributeType
        zIndex.isOptional = false
        zIndex.defaultValue = 0

        let shadowEnabled = NSAttributeDescription()
        shadowEnabled.name = "shadowEnabled"
        shadowEnabled.attributeType = .booleanAttributeType
        shadowEnabled.isOptional = false
        shadowEnabled.defaultValue = true

        let outlineEnabled = NSAttributeDescription()
        outlineEnabled.name = "outlineEnabled"
        outlineEnabled.attributeType = .booleanAttributeType
        outlineEnabled.isOptional = false
        outlineEnabled.defaultValue = false

        let brightness = NSAttributeDescription()
        brightness.name = "brightness"
        brightness.attributeType = .doubleAttributeType
        brightness.isOptional = false
        brightness.defaultValue = 0

        let cutoutApplied = NSAttributeDescription()
        cutoutApplied.name = "cutoutApplied"
        cutoutApplied.attributeType = .booleanAttributeType
        cutoutApplied.isOptional = false
        cutoutApplied.defaultValue = false

        let caption = NSAttributeDescription()
        caption.name = "caption"
        caption.attributeType = .stringAttributeType
        caption.isOptional = true

        let stickerCreatedAt = NSAttributeDescription()
        stickerCreatedAt.name = "createdAt"
        stickerCreatedAt.attributeType = .dateAttributeType
        stickerCreatedAt.isOptional = false

        let boardRelationship = NSRelationshipDescription()
        boardRelationship.name = "board"
        boardRelationship.destinationEntity = boardEntity
        boardRelationship.minCount = 1
        boardRelationship.maxCount = 1
        boardRelationship.deleteRule = .nullifyDeleteRule
        boardRelationship.inverseRelationship = nil

        let stickersRelationship = NSRelationshipDescription()
        stickersRelationship.name = "stickers"
        stickersRelationship.destinationEntity = stickerEntity
        stickersRelationship.minCount = 0
        stickersRelationship.maxCount = 0
        stickersRelationship.deleteRule = .cascadeDeleteRule
        stickersRelationship.inverseRelationship = boardRelationship

        boardRelationship.inverseRelationship = stickersRelationship

        stickerEntity.properties = [
            stickerId,
            stickerBoardId,
            imageFileName,
            positionX,
            positionY,
            scale,
            rotation,
            zIndex,
            shadowEnabled,
            outlineEnabled,
            brightness,
            cutoutApplied,
            caption,
            stickerCreatedAt,
            boardRelationship
        ]
        boardEntity.properties.append(stickersRelationship)

        model.entities = [boardEntity, stickerEntity]

        container = NSPersistentContainer(name: "CarAlbum", managedObjectModel: model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                assertionFailure("Failed to load CoreData store: \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

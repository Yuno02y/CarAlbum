import SwiftUI

struct BoardTemplate: Identifiable, Hashable {
    let id: String
    let title: String
    let slots: [CGRect]
    let showsTitleArea: Bool
}

enum TemplateLibrary {
    static let free = BoardTemplate(id: "free", title: "自由配置", slots: [], showsTitleArea: false)

    static let templates: [BoardTemplate] = [
        free,
        BoardTemplate(
            id: "hero",
            title: "1枚ヒーロー",
            slots: [CGRect(x: 0.1, y: 0.15, width: 0.8, height: 0.7)],
            showsTitleArea: false
        ),
        BoardTemplate(
            id: "split",
            title: "2分割（左右）",
            slots: [
                CGRect(x: 0.06, y: 0.12, width: 0.42, height: 0.76),
                CGRect(x: 0.52, y: 0.12, width: 0.42, height: 0.76)
            ],
            showsTitleArea: false
        ),
        BoardTemplate(
            id: "three",
            title: "3枚（大1 + 小2）",
            slots: [
                CGRect(x: 0.06, y: 0.12, width: 0.58, height: 0.76),
                CGRect(x: 0.68, y: 0.12, width: 0.26, height: 0.36),
                CGRect(x: 0.68, y: 0.52, width: 0.26, height: 0.36)
            ],
            showsTitleArea: false
        ),
        BoardTemplate(
            id: "grid",
            title: "4分割グリッド",
            slots: [
                CGRect(x: 0.08, y: 0.12, width: 0.4, height: 0.36),
                CGRect(x: 0.52, y: 0.12, width: 0.4, height: 0.36),
                CGRect(x: 0.08, y: 0.54, width: 0.4, height: 0.36),
                CGRect(x: 0.52, y: 0.54, width: 0.4, height: 0.36)
            ],
            showsTitleArea: false
        ),
        BoardTemplate(
            id: "poster",
            title: "整列済みポスター風",
            slots: [
                CGRect(x: 0.1, y: 0.2, width: 0.8, height: 0.55)
            ],
            showsTitleArea: true
        )
    ]

    static func template(for id: String?) -> BoardTemplate {
        templates.first { $0.id == id } ?? free
    }
}

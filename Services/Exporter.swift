import SwiftUI

final class Exporter {
    static let shared = Exporter()

    private init() {}

    @MainActor
    func renderBoard(view: some View, size: CGSize) -> UIImage? {
        let renderer = ImageRenderer(content: view.frame(width: size.width, height: size.height))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}

import Foundation
import UIKit

final class ImageStore {
    static let shared = ImageStore()

    private let fileManager = FileManager.default

    private init() {}

    func save(image: UIImage) -> String? {
        let fileName = "\(UUID().uuidString).png"
        guard let data = image.pngData() else { return nil }
        let url = documentsURL().appendingPathComponent(fileName)
        do {
            try data.write(to: url, options: [.atomic])
            return fileName
        } catch {
            return nil
        }
    }

    func loadImage(fileName: String) -> UIImage? {
        let url = documentsURL().appendingPathComponent(fileName)
        return UIImage(contentsOfFile: url.path)
    }

    func replaceImage(fileName: String, with image: UIImage) -> String? {
        let url = documentsURL().appendingPathComponent(fileName)
        guard let data = image.pngData() else { return nil }
        do {
            try data.write(to: url, options: [.atomic])
            return fileName
        } catch {
            return nil
        }
    }

    private func documentsURL() -> URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

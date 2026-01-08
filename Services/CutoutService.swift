import Foundation
import UIKit
import Vision

final class CutoutService {
    static let shared = CutoutService()

    private init() {}

    func cutout(image: UIImage) async -> UIImage {
        if #available(iOS 17.0, *) {
            return await performVisionCutout(image: image) ?? image
        } else {
            return image
        }
    }

    @available(iOS 17.0, *)
    private func performVisionCutout(image: UIImage) async -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
            guard let result = request.results?.first else { return nil }
            let maskPixelBuffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
            let ciImage = CIImage(cgImage: cgImage)
            let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)
            let filtered = ciImage.applyingFilter("CIBlendWithMask", parameters: [
                kCIInputMaskImageKey: maskImage
            ])
            let context = CIContext()
            guard let output = context.createCGImage(filtered, from: filtered.extent) else { return nil }
            return UIImage(cgImage: output)
        } catch {
            return nil
        }
    }
}

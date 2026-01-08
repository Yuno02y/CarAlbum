import SwiftUI

struct CutoutView: View {
    @EnvironmentObject private var store: BoardStore
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var sticker: StickerEntity

    @State private var previewImage: UIImage?
    @State private var isProcessing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 320)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    Image(systemName: "car")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                }

                if isProcessing {
                    ProgressView("切り抜き中…")
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("自動切り抜き")
                        .font(.headline)
                    Text("Visionで前景を抽出し、失敗時は手動調整(近日対応)に切り替えます。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    Task { await runCutout() }
                } label: {
                    Text("自動切り抜きを実行")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer()
            }
            .padding()
            .navigationTitle("切り抜き")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                previewImage = ImageStore.shared.loadImage(fileName: sticker.imageFileName)
            }
        }
    }

    private func runCutout() async {
        guard let image = ImageStore.shared.loadImage(fileName: sticker.imageFileName) else { return }
        isProcessing = true
        errorMessage = nil
        let result = await CutoutService.shared.cutout(image: image)
        previewImage = result
        _ = ImageStore.shared.replaceImage(fileName: sticker.imageFileName, with: result)
        sticker.cutoutApplied = true
        store.save()
        isProcessing = false
    }
}

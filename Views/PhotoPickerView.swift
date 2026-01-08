import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isLoading = false

    let onImagesPicked: ([UIImage]) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 10,
                    matching: .images
                ) {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 40))
                        Text("アルバムから選択")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                if isLoading {
                    ProgressView("読み込み中…")
                }

                Spacer()
            }
            .padding()
            .navigationTitle("アルバム")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedItems) { newItems in
                Task {
                    isLoading = true
                    var images: [UIImage] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            images.append(image)
                        }
                    }
                    isLoading = false
                    if !images.isEmpty {
                        onImagesPicked(images)
                        dismiss()
                    }
                }
            }
        }
    }
}

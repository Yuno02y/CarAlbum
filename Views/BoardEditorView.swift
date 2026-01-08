import SwiftUI
import PhotosUI
import CoreData

struct BoardEditorView: View {
    @EnvironmentObject private var store: BoardStore
    @State private var selectedStickerID: NSManagedObjectID?
    @State private var isShowingAddMenu = false
    @State private var isShowingPhotoPicker = false
    @State private var isShowingCamera = false
    @State private var isShowingBackgroundPicker = false
    @State private var isShowingStyleEditor = false
    @State private var isShowingCutout = false
    @State private var isShowingExporter = false
    @State private var isShowingAlignment = false
    @State private var shareImage: UIImage?
    @State private var canvasSize: CGSize = CGSize(width: 360, height: 520)

    let board: BoardEntity

    var body: some View {
        VStack(spacing: 12) {
            GeometryReader { proxy in
                let size = proxy.size
                BoardCanvasView(
                    board: board,
                    canvasSize: size,
                    selectedStickerID: selectedStickerID,
                    onSelect: { sticker in
                        selectedStickerID = sticker.objectID
                    }
                )
                .onAppear {
                    canvasSize = size
                }
                .onChange(of: size) { newValue in
                    canvasSize = newValue
                }
            }
            .aspectRatio(3 / 4, contentMode: .fit)
            .padding(.horizontal)

            BottomToolbar(
                onAdd: { isShowingAddMenu = true },
                onCutout: { isShowingCutout = true },
                onEdit: { isShowingStyleEditor = true },
                onAlign: { isShowingAlignment = true },
                onBackground: { isShowingBackgroundPicker = true },
                onExport: { exportBoard() }
            )
        }
        .padding(.bottom, 12)
        .navigationTitle(board.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    store.update(board: board)
                }
            }
        }
        .confirmationDialog("写真を追加", isPresented: $isShowingAddMenu, titleVisibility: .visible) {
            Button("アルバムから") {
                isShowingPhotoPicker = true
            }
            Button("カメラで撮影") {
                isShowingCamera = true
            }
        }
        .sheet(isPresented: $isShowingPhotoPicker) {
            PhotoPickerView { images in
                addImages(images)
            }
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraView { image in
                if let image {
                    addImages([image])
                }
            }
        }
        .sheet(isPresented: $isShowingBackgroundPicker) {
            BackgroundPickerView(board: board)
        }
        .sheet(isPresented: $isShowingStyleEditor) {
            if let sticker = selectedSticker {
                StickerStyleEditorView(sticker: sticker)
            } else {
                EmptyStateModal(title: "編集する写真を選択してください")
            }
        }
        .sheet(isPresented: $isShowingCutout) {
            if let sticker = selectedSticker {
                CutoutView(sticker: sticker)
            } else {
                EmptyStateModal(title: "切り抜き対象を選択してください")
            }
        }
        .sheet(isPresented: $isShowingExporter) {
            if let image = shareImage {
                ShareSheet(activityItems: [image])
            }
        }
        .confirmationDialog("整列", isPresented: $isShowingAlignment, titleVisibility: .visible) {
            Button("中央に整列") {
                alignSelectedSticker(horizontal: true, vertical: true)
            }
            Button("縦中央") {
                alignSelectedSticker(horizontal: false, vertical: true)
            }
            Button("横中央") {
                alignSelectedSticker(horizontal: true, vertical: false)
            }
            Button("グリッド吸着") {
                snapSelectedStickerToGrid()
            }
        }
    }

    private var selectedSticker: StickerEntity? {
        guard let selectedStickerID else { return nil }
        return board.stickers.first { $0.objectID == selectedStickerID }
    }

    private func addImages(_ images: [UIImage]) {
        let template = TemplateLibrary.template(for: board.templateId)
        let startIndex = board.stickers.count
        for (offset, image) in images.enumerated() {
            let slotIndex = startIndex + offset
            let rect = template.slots.indices.contains(slotIndex) ? template.slots[slotIndex] : nil
            store.addSticker(to: board, image: image, initialRect: rect, canvasSize: canvasSize)
        }
    }

    private func alignSelectedSticker(horizontal: Bool, vertical: Bool) {
        guard let sticker = selectedSticker else { return }
        var position = sticker.position
        if horizontal {
            position.x = 0
        }
        if vertical {
            position.y = 0
        }
        sticker.position = position
        store.save()
    }

    private func snapSelectedStickerToGrid() {
        guard let sticker = selectedSticker else { return }
        let grid: CGFloat = 20
        sticker.position = CGPoint(
            x: (sticker.positionX / grid).rounded() * grid,
            y: (sticker.positionY / grid).rounded() * grid
        )
        store.save()
    }

    private func exportBoard() {
        let view = BoardCanvasView(
            board: board,
            canvasSize: canvasSize,
            selectedStickerID: nil,
            onSelect: { _ in }
        )
        if let image = Exporter.shared.renderBoard(view: view, size: canvasSize) {
            shareImage = image
            isShowingExporter = true
        }
    }
}

private struct BottomToolbar: View {
    let onAdd: () -> Void
    let onCutout: () -> Void
    let onEdit: () -> Void
    let onAlign: () -> Void
    let onBackground: () -> Void
    let onExport: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            ToolbarButton(icon: "plus", title: "追加", action: onAdd)
            ToolbarButton(icon: "scissors", title: "切り抜き", action: onCutout)
            ToolbarButton(icon: "slider.horizontal.3", title: "編集", action: onEdit)
            ToolbarButton(icon: "square.grid.3x3", title: "整列", action: onAlign)
            ToolbarButton(icon: "paintpalette", title: "背景", action: onBackground)
            ToolbarButton(icon: "square.and.arrow.up", title: "書き出し", action: onExport)
        }
        .padding(.horizontal)
    }
}

private struct ToolbarButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.headline)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct EmptyStateModal: View {
    let title: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 36))
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

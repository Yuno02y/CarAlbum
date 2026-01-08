import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var store: BoardStore
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BoardEntity.updatedAt, ascending: false)],
        animation: .default
    )
    private var boards: FetchedResults<BoardEntity>

    @State private var isShowingTemplatePicker = false

    var body: some View {
        VStack(spacing: 16) {
            header
            if boards.isEmpty {
                emptyState
            } else {
                boardList
            }
        }
        .padding()
        .navigationTitle("CarAlbum")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingTemplatePicker = true
                } label: {
                    Label("新規ボード", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingTemplatePicker) {
            TemplatePickerView()
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("あなたの車フォトボード")
                    .font(.title2.bold())
                Text("旧車・スポーツカーの思い出をコラージュに")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("最初のボードを作成しましょう")
                .font(.headline)
            Button {
                isShowingTemplatePicker = true
            } label: {
                Text("テンプレートを選ぶ")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.accentColor.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var boardList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(boards) { board in
                    NavigationLink(destination: BoardEditorView(board: board)) {
                        BoardRow(board: board)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            store.delete(board: board)
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
}

private struct BoardRow: View {
    @EnvironmentObject private var store: BoardStore
    let board: BoardEntity

    var body: some View {
        HStack(spacing: 12) {
            BoardThumbnail(board: board)
                .frame(width: 72, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 6) {
                Text(board.title)
                    .font(.headline)
                Text(board.updatedAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("写真: \(board.stickers.count)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct BoardThumbnail: View {
    let board: BoardEntity

    var body: some View {
        ZStack {
            BackgroundStyle(rawValue: board.backgroundStyle)?.view() ?? Color(.systemBackground)
            if let imageName = board.sortedStickers.last?.imageFileName,
               let image = ImageStore.shared.loadImage(fileName: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

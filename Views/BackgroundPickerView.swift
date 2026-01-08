import SwiftUI

struct BackgroundPickerView: View {
    @EnvironmentObject private var store: BoardStore
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var board: BoardEntity

    var body: some View {
        NavigationStack {
            List(BackgroundStyle.allCases) { style in
                Button {
                    board.backgroundStyle = style.rawValue
                    store.update(board: board)
                    dismiss()
                } label: {
                    HStack {
                        style.view()
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Text(style.title)
                        Spacer()
                        if board.backgroundStyle == style.rawValue {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }
            .navigationTitle("背景")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

import SwiftUI

struct TemplatePickerView: View {
    @EnvironmentObject private var store: BoardStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(TemplateLibrary.templates) { template in
                Button {
                    _ = store.createBoard(template: template)
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(template.title)
                                .font(.headline)
                            Text(template.id == TemplateLibrary.free.id ? "自由に配置" : "自動レイアウト")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        TemplatePreview(template: template)
                            .frame(width: 72, height: 96)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("テンプレ選択")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct TemplatePreview: View {
    let template: BoardTemplate

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                ForEach(Array(template.slots.enumerated()), id: \.offset) { _, slot in
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                        .foregroundStyle(.secondary)
                        .frame(width: slot.width * proxy.size.width, height: slot.height * proxy.size.height)
                        .position(
                            x: slot.midX * proxy.size.width,
                            y: slot.midY * proxy.size.height
                        )
                }
                if template.showsTitleArea {
                    Text("TITLE")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .position(x: proxy.size.width / 2, y: proxy.size.height * 0.1)
                }
            }
        }
    }
}

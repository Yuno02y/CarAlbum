import SwiftUI

struct StickerStyleEditorView: View {
    @EnvironmentObject private var store: BoardStore
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var sticker: StickerEntity

    var body: some View {
        NavigationStack {
            Form {
                Section("スタイル") {
                    Toggle("影", isOn: Binding(
                        get: { sticker.shadowEnabled },
                        set: { sticker.shadowEnabled = $0; store.save() }
                    ))
                    Toggle("縁取り", isOn: Binding(
                        get: { sticker.outlineEnabled },
                        set: { sticker.outlineEnabled = $0; store.save() }
                    ))
                    VStack(alignment: .leading) {
                        Text("明るさ")
                        Slider(value: Binding(
                            get: { sticker.brightness },
                            set: { sticker.brightness = $0; store.save() }
                        ), in: -0.5...0.5)
                    }
                }

                Section("キャプション") {
                    TextField("例: NA8C / 箱根 / 2026-01-08", text: Binding(
                        get: { sticker.caption ?? "" },
                        set: { sticker.caption = $0; store.save() }
                    ))
                }
            }
            .navigationTitle("編集")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}

//
//  CarAlbumApp.swift
//  CarAlbum
//
//  Created by K on 2026/01/08.
//

import SwiftUI

@main
struct CarAlbumApp: App {
    @StateObject private var boardStore = BoardStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, boardStore.context)
                .environmentObject(boardStore)
        }
    }
}

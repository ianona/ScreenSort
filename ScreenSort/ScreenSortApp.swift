//
//  ScreenSortApp.swift
//  ScreenSort
//
//  Created by ianona on 2024/2/21.
//

import SwiftUI

@main
struct ScreenSortApp: App {
    let photoLibraryService = PhotoLibraryService()
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(photoLibraryService)
    }
}

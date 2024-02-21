//
//  ScreenSortApp.swift
//  ScreenSort
//
//  Created by ianona on 2024/2/21.
//

import SwiftUI

@main
struct ScreenSortApp: App {
    @StateObject var dataModel = DataModel()
    var body: some Scene {
        WindowGroup {
            NavigationStack {
               GridView()
           }
           .environmentObject(dataModel)
           .navigationViewStyle(.stack)
        }
    }
}

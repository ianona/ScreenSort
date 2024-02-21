//
//  Item.swift
//  ScreenSort
//
//  Created by ianona on 2024/2/21.
//

import SwiftUI

struct Item: Identifiable {
    let id = UUID()
    let url: URL
}

extension Item: Equatable {
    static func ==(lhs:Item, rhs:Item) -> Bool {
        return lhs.id == rhs.id && lhs.id == rhs.id
    }
}

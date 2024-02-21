//
//  GridItemView.swift
//  ScreenSort
//
//  Created by ianona on 2024/2/21.
//

import SwiftUI

struct GridItemView: View {
    let size: Double
    let item: Item


    var body: some View {
        ZStack(alignment: .topTrailing) {
            AsyncImage(url: item.url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: size, height: size)
        }
    }
}


struct GridItemView_Previews: PreviewProvider {
    static var previews: some View {
        if let url = Bundle.main.url(forResource: "mushy1", withExtension: "jpg") {
            GridItemView(size: 50, item: Item(url: url))
        }
    }
}

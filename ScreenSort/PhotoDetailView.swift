//
//  PhotoDetailView.swift
//  ScreenSort
//
//  Created by ianona on 2024/3/6.
//

import SwiftUI

struct PhotoDetailView: View {
    @EnvironmentObject var photoLibraryService: PhotoLibraryService
    /// The image view that will render the photo that we'll fetch
    /// later on. It is set to optional since we don't have an actual
    /// photo when this scene starts to render. We need to give time
    /// for the photo library service to fetch a cached copy
    /// of the photo using the asset id, so we'll set the image with
    /// the fetching photo at a later time.
    ///
    /// Fetching is generally fast, as photos are cached at this
    /// point. So you don't need to worry about photo rendering.
    ///
    /// Also, we would want to free up the image from the memory when
    /// this view disappears to save up memory.
    @State private var image: Image?
    /// The reference id of the selected photo
    private var assetLocalId: String
    /// Flag that will close the detail view if set to false
    @Binding var showDetailView: Bool
        
    init(
        assetLocalId:String,
        showDetailView: Binding<Bool>
    ) {
        self._showDetailView = showDetailView
        self.assetLocalId = assetLocalId
    }

    var body: some View {
        ZStack {
            // We'll need a black background regardless of the
            // environment's colour scheme.
            Color.black.ignoresSafeArea()
            
            // Show the image if it's available
            if let _ = image {
                photoView
            } else {
                // otherwise, show a spinning progress view
                ProgressView()
            }
        }
        .overlay(toolbarView)
        // We need to use the task to work on a concurrent request to
        // load the image from the photo library service, which is an
        // asynchronous work.
        .task {
            await loadImageAsset()
        }
        // Finally, when the view disappears, we need to free it up
        // from the memory
        .onDisappear {
            image = nil
        }
    }
}

extension PhotoDetailView {
    func loadImageAsset() async {
        guard let uiImage = try? await photoLibraryService.fetchImage(
            byLocalIdentifier: assetLocalId
        ) else {
            image = nil
            return
        }
        image = Image(uiImage: uiImage)
    }
}

extension PhotoDetailView {
    var photoView: some View {
        GeometryReader { proxy in
            image?
                .resizable()
                .aspectRatio(contentMode: .fit)
//                .frame(width: proxy.size.width * max(minZoomScale, zoomScale))
                .frame(maxHeight: .infinity)
        }
    }
    
    var toolbarView: some View {
        HStack {
            closeButton
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, 20)
        .frame(height: 44)
        .frame(maxHeight: .infinity, alignment: .top)
    }
        
    var closeButton: some View {
        Button {
            showDetailView = false
        } label: {
            Image(systemName: "xmark")
                .font(.body.bold())
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .frame(width: 16, height: 16)
                .padding(.all, 12)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}

//#Preview {
//    PhotoDetailView()
//}

//
//  PhotoThumbnailView.swift
//  ScreenSort
//
//  Created by ianona on 2024/3/6.
//
import Photos
import SwiftUI

struct PhotoThumbnailView: View {
    /// We'll use the photo library service to fetch a photo given an
    /// asset id, and cache it for later use. If the photo is already
    /// cached, a cached copy will be provided instead.
    ///
    /// Ideally, we don't want to store a reference to an image
    /// itself and pass it around views as it would cost memory.
    /// We'll use the asset id instead as a reference, and allow the
    /// photo library's cache to handle any memory management for us.
    @EnvironmentObject var photoLibraryService: PhotoLibraryService
    
    /// The image view that will render the photo that we'll be
    /// fetching. It is set to optional since we don't have an actual
    /// photo when this view starts to render.
    ///
    /// We need to give time for the photo library service to
    /// fetch a copy of the photo using the asset id, so
    /// we'll set the image with the fetched photo at a later time.
    ///
    /// Fetching make take time, especially if the photo has been
    /// requested initially. However, photos that were successfully
    /// fetched are cached, so any fetching from that point forward
    /// will be fast.
    ///
    /// Also, we would want to free up the image from the memory when
    /// this view disappears in order
    /// to save up memory.
    @State private var image: Image?
    
    /// The reference id of the selected photo
    private var assetLocalId: String
    
    init(assetLocalId: String) {
        self.assetLocalId = assetLocalId
    }
    var body: some View {
        ZStack {
            // Show the image if it's available
            if let image = image {
                GeometryReader { proxy in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: proxy.size.width,
                            height: proxy.size.width
                        )
                        .clipped()
                }
                // We'll also make sure that the photo will
                // be square
                .aspectRatio(1, contentMode: .fit)
            } else {
                // Otherwise, show a gray rectangle with a
                // spinning progress view
                Rectangle()
                    .foregroundColor(.gray)
                    .aspectRatio(1, contentMode: .fit)
                ProgressView()
            }
        }
        // We need to use the task to work on a concurrent request to
        // load the image from the photo library service, which
        // is asynchronous work.
        .task {
            await loadImageAsset()
        }
        // Finally, when the view disappears, we need to free it
        // up from the memory
        .onDisappear {
            image = nil
        }
    }
}

extension PhotoThumbnailView {
    func loadImageAsset(
        targetSize: CGSize = PHImageManagerMaximumSize
    ) async {
        guard let uiImage = try? await photoLibraryService
            .fetchImage(
                byLocalIdentifier: assetLocalId,
                targetSize: targetSize
            ) else {
            image = nil
            return
        }
        image = Image(uiImage: uiImage)
    }
}

//#Preview {
//    PhotoThumbnailView()
//}

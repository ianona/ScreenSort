//
//  ContentView.swift
//  ScreenSort
//
//  Created by ianona on 2024/2/21.
//

import SwiftUI
import Photos

struct ContentView: View {
    /// Photo library will ask for permission to ask the user for
    /// Photo access, and will provide the photos as well.
    @EnvironmentObject var photoLibraryService: PhotoLibraryService
    
    /// Frag that will show the error prompt if the user does not
    /// grant the app Photo access.
    @State private var showErrorPrompt = false
    
    /// Flag that will show the detail view when a photo is selected
    /// from the grid.
    @State private var showDetailView = false
    /// Selecting a photo from the grid will show a detail view where
    /// the user can zoom/pan.
    /// To do so, we store a reference to the selected photo
    /// here.
    @State private var selectedPhotoAssetId = ""
    var body: some View {
        VStack {
            Text("Screenshots")
                .font(.title.bold())
            ZStack {
                // We'll show the photo library in a grid
                libraryView
                    .onAppear {
                        // But first we need to make sure we got
                        // permission to Access the Photos library
                        requestForAuthorizationIfNecessary()
                    }
                    .alert(
                        // If in case the user won't grant permission,
                        // we'll show an alert to notify the user that
                        // access is required to use the app.
                        Text("This app requires photo library access to show your photos"),
                        isPresented: $showErrorPrompt
                    ) {}
            }
        }
    }
    
}

extension ContentView {
    func requestForAuthorizationIfNecessary() {
        // Make sure that the access granted by the user is
        // authorized, or limited access to make the app work. As
        // long as access is granted, even when limited, we can have
        // the photo library fetch the photos to be shown in the app.
        guard photoLibraryService.authorizationStatus != .authorized ||
                photoLibraryService.authorizationStatus != .limited
        else { return }
        photoLibraryService.requestAuthorization { error in
            guard error != nil else { return }
            showErrorPrompt = true
        }
    }
}

extension ContentView {
    var libraryView: some View {
        ScrollView {
            LazyVGrid(
                /// We'll set a 3-column row with an adaptive width
                /// of 100 for each grid item, and give it a spacing
                /// of 1 pixel in between columns and in between rows
                columns: Array(
                    repeating: .init(.adaptive(minimum: 100), spacing: 1),
                    count: 3
                ),
                spacing: 1
            ) {
                /// We'll go through the photo references fetched by
                /// the photo gallery and give a photo asset ID
                /// into the PhotoThumbnailView so it knows what
                /// image to load and show into the grid
                ForEach(photoLibraryService.results, id: \.self) { asset in
                    /// Wrap the PhotoThumbnailView into a button
                    /// so we can tap on it without overlapping
                    /// the tap area of each photo, as photos have
                    /// their aspect ratios, and may go out of
                    /// bounds of the square view.
                    Button {
                        /// Add them here
                        showDetailView = true
                        selectedPhotoAssetId = asset.localIdentifier
                    } label: {
                        PhotoThumbnailView(assetLocalId: asset.localIdentifier)
                    }
                }
            }
        }
    }
    
//    var detailView: some View {
//        ForEach(photoLibraryService.results, id: \.self) { asset in
//            if asset.localIdentifier == selectedPhotoAssetId {
//                PhotoDetailView(
//                    assetLocalId: selectedPhotoAssetId,
//                    showDetailView: $showDetailView
//                )
//                // We need to make sure that the detail view gets the
//                // top layer of the ZStack when rendering. We don't
//                // want to hide the detail view underneath the photo
//                // grid when we select a photo. So we'll assign it a
//                // higher zIndex value.
//                .zIndex(1)
//                // We would also want to add a small transition
//                // easeIn/easeOut animations during the
//                // photo grid to detail view transition and vice
//                // versa.
//                .transition(
//                    .asymmetric(
//                        insertion: .opacity.animation(.easeIn),
//                        removal: .opacity.animation(.easeOut)
//                    )
//                )
//            }
//        }
//    }
}

#Preview {
    ContentView()
}

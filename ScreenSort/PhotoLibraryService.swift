//
//  PhotoLibraryService.swift
//  ScreenSort
//
//  Created by ianona on 2024/3/6.
//

import Foundation
import Photos
import UIKit

// Define AuthorizationError type
enum AuthorizationError: Error {
    case unauthorized
    case forbidden
    case restrictedAccess
}

enum QueryError: Error {
    case phAssetNotFound
}
struct PHFetchResultCollection: RandomAccessCollection, Equatable {
    typealias Element = PHAsset
    typealias Index = Int

    var fetchResult: PHFetchResult<PHAsset>

    var endIndex: Int { fetchResult.count }
    var startIndex: Int { 0 }

    subscript(position: Int) -> PHAsset {
        fetchResult.object(at: fetchResult.count - position - 1)
    }
}

class PhotoLibraryService: ObservableObject {
    // The permission status granted by the user
    // This property will determine if we need to request
    // for library access or not
    var authorizationStatus: PHAuthorizationStatus = .notDetermined
    // The manager that will fetch and cache photos for us
    var imageCachingManager = PHCachingImageManager()
    

    @Published var results = PHFetchResultCollection(fetchResult: .init())
    
    func requestAuthorization(
        handleError: ((AuthorizationError?) -> Void)? = nil
    ) {
        /// This is the code that does the permission requests
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            self?.authorizationStatus = status
            /// We can determine permission granted by the status
            switch status {
            /// Fetch all photos if the user granted us access
            /// This won't be the photos themselves but the
            /// references only.
            case .authorized, .limited:
                self?.fetchAllPhotos()
            
            /// For denied response, we should show an error
            case .denied, .notDetermined, .restricted:
                handleError?(.restrictedAccess)
                
            @unknown default:
                break
            }
        }
    }
    
    private func fetchAllPhotos() {
        imageCachingManager.allowsCachingHighQualityImages = false
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = false
        fetchOptions.includeAssetSourceTypes = .typeUserLibrary
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)

        // Filter assets to include only screenshots
        if #available(iOS 9.0, *) {
            fetchOptions.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                fetchOptions.predicate!,
                NSPredicate(format: "mediaSubtype = %d", PHAssetMediaSubtype.photoScreenshot.rawValue)
            ])
        } else {
            // Fallback on earlier versions
            fetchOptions.predicate = NSPredicate(format: "localIdentifier IN %@", PHAsset.fetchAssets(with: fetchOptions).objects(at: IndexSet(integer: fetchOptions.fetchLimit)).compactMap { $0.localIdentifier })
        }
        
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        DispatchQueue.main.async {
            self.results.fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        }
    }
    
    /// Requests an image copy given a photo asset id.
    ///
    /// The image caching manager performs the fetching, and will
    /// cache the photo fetched for later use. Please know that the
    /// cache is temporary – all photos cached will be lost when the
    /// app is terminated.
    func fetchImage(
        byLocalIdentifier localId: String,
        targetSize: CGSize = PHImageManagerMaximumSize,
        contentMode: PHImageContentMode = .default
    ) async throws -> UIImage? {
        let results = PHAsset.fetchAssets(
            withLocalIdentifiers: [localId],
            options: nil
        )
    
        guard let asset = results.firstObject else {
            throw QueryError.phAssetNotFound
        }
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            /// Use the imageCachingManager to fetch the image
            self?.imageCachingManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: contentMode,
                options: options,
                resultHandler: { image, info in
                    /// image is of type UIImage
                    if let error = info?[PHImageErrorKey] as? Error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: image)
                }
            )
        }
    }
}

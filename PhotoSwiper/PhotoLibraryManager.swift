//
//  PhotoLibraryManager.swift
//  PhotoSwiper
//
//  Created by Selma Sahin on 09.05.2025.
//

import Foundation
import SwiftUI
import Photos

class PhotoLibraryManager: ObservableObject {
    @Published var assets: [PHAsset] = []
    private var deleteAlbum: PHAssetCollection?
    private var fetchOffset = 0  // Track the number of photos we've already fetched
    private let fetchLimit = 100  // Number of photos to load per fetch
    init() {
        requestAccessAndLoadPhotos()
    }

    func requestAccessAndLoadPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                self.fetchDeleteAlbum()
                self.loadPhotos()
                print("Status authourized")
            } else {
                print("Access denied")
            }
        }
    }

    private func fetchDeleteAlbum() {
        // Look for existing album
        let albumName = "To Delete"
        let fetch = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)

        fetch.enumerateObjects { collection, _, stop in
            if collection.localizedTitle == albumName {
                self.deleteAlbum = collection
                stop.pointee = true
            }
        }

        // Create album if not found
        if deleteAlbum == nil {
            var albumPlaceholder: PHObjectPlaceholder?

            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }) { success, error in
                if success, let placeholder = albumPlaceholder {
                    let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                    self.deleteAlbum = fetchResult.firstObject
                } else {
                    print("Failed to create album: \(error?.localizedDescription ?? "unknown error")")
                }
            }
        }
    }

    func loadPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = fetchLimit  // Limit the number of photos per request

        // We need to ensure we're starting from the correct offset
        let results = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        // Handle fetching in the background, then add new assets to the array
        DispatchQueue.main.async {
            let newAssets = (0..<results.count).compactMap { results.object(at: $0) }
            self.assets.append(contentsOf: newAssets)
            self.fetchOffset += results.count  // Update the offset for the next batch
        }
    }
    
    func moveToDeleteAlbum(asset: PHAsset) {
        guard let deleteAlbum = deleteAlbum else {
            print("Delete album not ready")
            return
        }

        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCollectionChangeRequest(for: deleteAlbum)
            request?.addAssets([asset] as NSArray)
        }) { success, error in
            if success {
                print("Moved to 'To Delete' album")
            } else {
                print("Error moving photo: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }
}

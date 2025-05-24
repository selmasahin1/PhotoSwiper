//
//  ContentView.swift
//  PhotoSwiper
//
//  Created by Selma Sahin on 04.05.2025.
//

import SwiftData
import SwiftUI

struct ContentView: View {

    @AppStorage("currentPhotoIndex") private var currentIndex = 0
    @StateObject var photoManager = PhotoLibraryManager()

    var body: some View {
        VStack {
            Button(action: {
                currentIndex = 0
            }) {
                Text("Reset")
                    .padding(.horizontal, 25)
                    .padding(.vertical, 10)
                    .background(Color(hex: 0x9090D1))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 50)
            .padding(.trailing, 20)
            
            if currentIndex < photoManager.assets.count {
                PhotoSortView(
                    asset: photoManager.assets[currentIndex],
                    onSwipeLeft: {
                        photoManager.moveToDeleteAlbum(
                            asset: photoManager.assets[currentIndex])
                        currentIndex += 1  // Move to the next photo
                        loadMorePhotosIfNeeded()
                    },
                    onSwipeRight: {
                        currentIndex += 1  // Move to the next photo
                        loadMorePhotosIfNeeded()
                    },
                    onDoubleTap: {
                        currentIndex -= 1
                    }
                )
            } else {
                Text("No more photos!")
                    .padding()
            }
            
        }
        .onChange(of: currentIndex) { newValue, oldValue in
            if newValue >= photoManager.assets.count {
                currentIndex = photoManager.assets.count - 1
            }
        }
        .onAppear {
            // Ensure assets are loaded when view appears
            print("new photo loading")
            photoManager.loadPhotos()
        }
    }

    private func loadMorePhotosIfNeeded() {
        // If the current index is near the end of the list, load more photos
        if currentIndex >= photoManager.assets.count - 1 {
            print("Loading more photos...")
            photoManager.loadPhotos()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

//
//  PhotoSortView.swift
//  PhotoSwiper
//
//  Created by Selma Sahin on 04.05.2025.
//

import Photos
import PhotosUI
import SwiftUI

struct PhotoSortView: View {
    let asset: PHAsset
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void

    @State private var uiImage: UIImage? = nil
    @State private var offset: CGSize = .zero

    var body: some View {
        VStack(spacing: 0) {
            // Top 3/4 container (e.g. photo preview)
            ZStack {
                Color.gray.opacity(0.1)
                
                if let image = uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .id(image)
                } else {
                    Text("Loading...")
                }
            }
            .frame(maxHeight: .infinity)
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { gesture in
                        if offset.width < -100 {
                            onSwipeLeft()
                        } else if offset.width > 100 {
                            onSwipeRight()
                        }
                        // Reset offset after swipe
                        withAnimation {
                            offset = .zero
                        }
                    }
            )
            .animation(.spring(), value: offset)

            // Bottom 1/4 with buttons
            HStack {
                Spacer()

                // Trash Button
                Button(action: {
                    onSwipeRight()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color(hex: 0x120C6E))
                        .clipShape(Circle())
                }

                Spacer()

                // Arrow Button
                Button(action: {
                    onSwipeLeft()
                }) {
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color(hex: 0x5E772EB))
                        .clipShape(Circle())
                }

                Spacer()
            }
            .padding(.vertical, 60)
            .background(Color(UIColor.systemBackground))
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            print("📥 PhotoSortView appeared, loading image...")
            loadImage()
        }
        .onChange(of: asset) { oldAsset, newAsset in
            print("📤 Asset changed, loading new image...")
            loadImage()  // Reload image whenever the asset changes
        }
    }

    private func swipeLeft() {
        print("buttonClicked")
    }

    func loadImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat

        manager.requestImage(
            for: asset, targetSize: CGSize(width: 1000, height: 1000),
            contentMode: .aspectFit, options: options
        ) { image, _ in
            DispatchQueue.main.async {
                if let img = image {
                    print("✅ Image loaded: \(img.size)")
                } else {
                    print("❌ Image failed to load")
                }
                self.uiImage = image
            }        }
    }
}

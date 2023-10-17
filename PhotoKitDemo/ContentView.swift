//
//  ContentView.swift
//  PhotoKitDemo
//
//  Created by vignesh kumar c on 17/10/23.
//

import SwiftUI
import Photos

struct PhotoGalleryView: View {
    @State private var photos: [PhotoAsset] = []
    @State private var selectedPhoto: PhotoAsset?
    
    var body: some View {
        NavigationView {
            List(photos) { photo in
                Button(action: {
                    selectedPhoto = photo
                }) {
                    Image(uiImage: photo.thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipped()
                }
            }
            .navigationTitle("Photo Gallery")
        }
        .sheet(item: $selectedPhoto) { photo in
            PhotoDetailView(photo: photo.asset)
        }
        .onAppear {
            fetchPhotos()
        }
    }
    
    func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var assets: [PhotoAsset] = []
        let group = DispatchGroup()
        
        fetchResult.enumerateObjects { asset, _, _ in
            group.enter()
            PhotoAsset.loadThumbnail(for: asset) { thumbnail in
                assets.append(PhotoAsset(asset: asset, thumbnail: thumbnail))
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            photos = assets
        }
    }
}

struct PhotoAsset: Identifiable {
    var id = UUID()
    var asset: PHAsset
    var thumbnail: UIImage
    
    init(asset: PHAsset, thumbnail: UIImage) {
        self.asset = asset
        self.thumbnail = thumbnail
    }
    
    static func loadThumbnail(for asset: PHAsset, completion: @escaping (UIImage) -> Void) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        
        manager.requestImage(for: asset, targetSize: CGSize(width: 80, height: 80), contentMode: .aspectFill, options: options) { result, _ in
            if let result = result {
                completion(result)
            }
        }
    }
}

struct PhotoDetailView: View {
    var photo: PHAsset
    
    var body: some View {
        Text("Detail view for photo")
    }
}

#Preview {
    PhotoGalleryView()
}

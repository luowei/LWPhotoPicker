//
// LWPhotoPicker.swift
// LWPhotoPicker
//
// Created by Luo Wei on 2017/4/22.
// Copyright (c) 2017 luowei. All rights reserved.
// Swift/SwiftUI version
//

import UIKit
import Photos

// MARK: - LWPhotoAlbumList

/// Represents a photo album with metadata
public class LWPhotoAlbumList {
    /// Album name
    public var title: String = ""

    /// Number of photos in the album
    public var count: Int = 0

    /// First image asset in the album (for thumbnail)
    public var headImageAsset: PHAsset?

    /// Asset collection to access all photos in the album
    public var assetCollection: PHAssetCollection?

    public init() {}
}

// MARK: - LWPhotoModel

/// Model representing a photo asset
public class LWPhotoModel {
    public var asset: PHAsset?
    public var localIdentifier: String?

    public init() {}
}

// MARK: - LWPhotoPicker

/// Main photo picker class for accessing and managing photos from the photo library
public class LWPhotoPicker {

    private let collectionName: String

    public init() {
        self.collectionName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "App"
    }

    // MARK: - Save Image to Album

    /// Save image to system album
    /// - Parameters:
    ///   - image: Image to save
    ///   - completion: Completion handler with success status and asset
    public func saveImage(toAlbum image: UIImage, completion: ((Bool, PHAsset?) -> Void)?) {
        let status = PHPhotoLibrary.authorizationStatus()

        guard status != .denied && status != .restricted else {
            completion?(false, nil)
            return
        }

        var assetId: String?

        PHPhotoLibrary.shared().performChanges {
            assetId = PHAssetCreationRequest.creationRequestForAsset(from: image)
                .placeholderForCreatedAsset?.localIdentifier
        } completionHandler: { success, error in
            guard success, let assetId = assetId else {
                completion?(false, nil)
                return
            }

            let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).lastObject

            guard let desCollection = self.getDestinationCollection() else {
                completion?(false, nil)
                return
            }

            // Save image to custom album
            PHPhotoLibrary.shared().performChanges {
                PHAssetCollectionChangeRequest(for: desCollection)?.addAssets([asset] as NSArray)
            } completionHandler: { success, error in
                completion?(success, asset)
            }
        }
    }

    // MARK: - Get Custom Album

    /// Get or create destination collection
    private func getDestinationCollection() -> PHAssetCollection? {
        // Check if custom album already exists
        let collectionResult = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .albumRegular,
            options: nil
        )

        for i in 0..<collectionResult.count {
            let collection = collectionResult.object(at: i)
            if collection.localizedTitle == collectionName {
                return collection
            }
        }

        // Create new custom album
        var collectionId: String?
        do {
            try PHPhotoLibrary.shared().performChangesAndWait {
                collectionId = PHAssetCollectionChangeRequest
                    .creationRequestForAssetCollection(withTitle: collectionName)
                    .placeholderForCreatedAssetCollection.localIdentifier
            }
        } catch {
            print("Failed to create album: \(collectionName)")
            return nil
        }

        guard let collectionId = collectionId else { return nil }
        return PHAssetCollection.fetchAssetCollections(
            withLocalIdentifiers: [collectionId],
            options: nil
        ).lastObject
    }

    // MARK: - Get Album List

    /// Get all photo album lists
    /// - Returns: Array of photo album lists
    public func getPhotoAlbumList() -> [LWPhotoAlbumList] {
        var photoAlbumList: [LWPhotoAlbumList] = []

        // Get all smart albums
        let smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .albumRegular,
            options: nil
        )

        smartAlbums.enumerateObjects { collection, _, _ in
            // Filter out videos and recently deleted
            if collection.assetCollectionSubtype != .smartAlbumVideos &&
                collection.assetCollectionSubtype.rawValue < 212 {
                let assets = self.getAssets(in: collection, ascending: false)
                if !assets.isEmpty {
                    let album = LWPhotoAlbumList()
                    album.title = collection.localizedTitle ?? ""
                    album.count = assets.count
                    album.headImageAsset = assets.first
                    album.assetCollection = collection
                    photoAlbumList.append(album)
                }
            }
        }

        // Get user created albums
        let userAlbums = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .smartAlbumUserLibrary,
            options: nil
        )

        userAlbums.enumerateObjects { collection, _, _ in
            let assets = self.getAssets(in: collection, ascending: false)
            if !assets.isEmpty {
                let album = LWPhotoAlbumList()
                album.title = collection.localizedTitle ?? ""
                album.count = assets.count
                album.headImageAsset = assets.first
                album.assetCollection = collection
                photoAlbumList.append(album)
            }
        }

        return photoAlbumList
    }

    // MARK: - Fetch Assets

    private func fetchAssets(in assetCollection: PHAssetCollection, ascending: Bool) -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: ascending)]
        return PHAsset.fetchAssets(in: assetCollection, options: options)
    }

    // MARK: - Get All Assets in Photo Album

    /// Get all image assets in photo album
    /// - Parameter ascending: Sort by creation date ascending (true) or descending (false)
    /// - Returns: Array of photo assets
    public func getAllAssets(inPhotoAlbum ascending: Bool) -> [PHAsset] {
        var assets: [PHAsset] = []

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: ascending)]

        let result = PHAsset.fetchAssets(with: .image, options: options)

        result.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }

        return assets
    }

    // MARK: - Get Assets in Asset Collection

    /// Get all image assets in specified collection
    /// - Parameters:
    ///   - assetCollection: Asset collection
    ///   - ascending: Sort by creation date ascending (true) or descending (false)
    /// - Returns: Array of photo assets
    public func getAssets(in assetCollection: PHAssetCollection, ascending: Bool) -> [PHAsset] {
        var assets: [PHAsset] = []

        let result = fetchAssets(in: assetCollection, ascending: ascending)
        result.enumerateObjects { obj, _, _ in
            if obj.mediaType == .image {
                assets.append(obj)
            }
        }

        return assets
    }

    // MARK: - Request Image for Asset

    /// Request image for asset
    /// - Parameters:
    ///   - asset: Photo asset
    ///   - size: Target size
    ///   - synchronous: Whether to request synchronously
    ///   - completion: Completion handler with image and info
    public func requestImage(
        for asset: PHAsset,
        size: CGSize,
        synchronous: Bool,
        completion: @escaping (UIImage?, [AnyHashable: Any]?) -> Void
    ) {
        static var requestID: PHImageRequestID = -1

        let scale = UIScreen.main.scale
        let screenWidth = UIScreen.main.bounds.width
        let width = screenWidth > 1000 ? 1000 : screenWidth

        if requestID >= 1 && size.width / width == scale {
            PHCachingImageManager.default().cancelImageRequest(requestID)
        }

        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.isSynchronous = synchronous
        options.isNetworkAccessAllowed = true

        requestID = PHCachingImageManager.default().requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFit,
            options: options
        ) { image, info in
            let isCancelled = (info?[PHImageCancelledKey] as? Bool) ?? false
            let hasError = info?[PHImageErrorKey] != nil
            let downloadFinished = !isCancelled && !hasError

            if downloadFinished {
                completion(image, info)
            }
        }
    }

    /// Request image data for asset with scale
    /// - Parameters:
    ///   - asset: Photo asset
    ///   - scale: Scale factor
    ///   - resizeMode: Resize mode
    ///   - completion: Completion handler with image
    public func requestImage(
        for asset: PHAsset,
        scale: CGFloat,
        resizeMode: PHImageRequestOptionsResizeMode,
        completion: @escaping (UIImage?) -> Void
    ) {
        let options = PHImageRequestOptions()
        options.resizeMode = resizeMode
        options.isNetworkAccessAllowed = true

        PHCachingImageManager.default().requestImageDataAndOrientation(
            for: asset,
            options: options
        ) { imageData, dataUTI, orientation, info in
            guard let imageData = imageData else { return }

            let isCancelled = (info?[PHImageCancelledKey] as? Bool) ?? false
            let hasError = info?[PHImageErrorKey] != nil
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
            let downloadFinished = !isCancelled && !hasError && !isDegraded

            if downloadFinished {
                guard let image = UIImage(data: imageData) else { return }

                if let jpegData = image.jpegData(compressionQuality: 1.0) {
                    let compressionScale = CGFloat(imageData.count) / CGFloat(jpegData.count)
                    let finalScale = scale == 1 ? compressionScale : compressionScale / 2

                    if let compressedData = image.jpegData(compressionQuality: finalScale),
                       let compressedImage = UIImage(data: compressedData) {
                        completion(compressedImage)
                    }
                }
            }
        }
    }

    // MARK: - Get Photos Bytes

    /// Get total bytes of photos in array
    /// - Parameters:
    ///   - photos: Array of photo models
    ///   - completion: Completion handler with formatted bytes string
    public func getPhotosBytes(withArray photos: [LWPhotoModel], completion: @escaping (String) -> Void) {
        var dataLength = 0
        var count = photos.count

        for model in photos {
            guard let asset = model.asset else { continue }

            PHCachingImageManager.default().requestImageDataAndOrientation(
                for: asset,
                options: nil
            ) { imageData, dataUTI, orientation, info in
                if let imageData = imageData {
                    dataLength += imageData.count
                }
                count -= 1

                if count <= 0 {
                    completion(self.transformDataLength(dataLength))
                }
            }
        }
    }

    private func transformDataLength(_ dataLength: Int) -> String {
        if dataLength >= Int(0.1 * 1024 * 1024) {
            return String(format: "%.1fM", Double(dataLength) / 1024 / 1024)
        } else if dataLength >= 1024 {
            return String(format: "%.0fK", Double(dataLength) / 1024)
        } else {
            return "\(dataLength)B"
        }
    }

    // MARK: - Judge Asset in Local Album

    /// Check if asset is stored locally or downloaded from iCloud
    /// - Parameter asset: Photo asset
    /// - Returns: True if asset is in local album
    public func judgeAssetIsInLocalAlbum(_ asset: PHAsset) -> Bool {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = false
        options.isSynchronous = true

        var isInLocalAlbum = true

        PHCachingImageManager.default().requestImageDataAndOrientation(
            for: asset,
            options: options
        ) { imageData, dataUTI, orientation, info in
            isInLocalAlbum = imageData != nil
        }

        return isInLocalAlbum
    }
}

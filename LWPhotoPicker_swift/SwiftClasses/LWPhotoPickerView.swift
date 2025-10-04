//
// LWPhotoPickerView.swift
// LWPhotoPicker
//
// Created by Luo Wei on 2017/3/4.
// Copyright © 2017 luowei. All rights reserved.
// Swift/SwiftUI version
//

import SwiftUI
import Photos

// MARK: - LWPhotoPickerView (SwiftUI)

/// SwiftUI photo picker view with fixed aspect ratio
public struct LWPhotoPickerView: View {
    @StateObject private var viewModel: PhotoPickerViewModel

    private let outSize: CGSize
    private let itemSize: CGSize
    private let pickedBlock: (UIImage) -> Void

    public init(
        frame: CGRect,
        outSize: CGSize,
        pickedBlock: @escaping (UIImage) -> Void
    ) {
        let calculatedItemSize = CGSize(
            width: (frame.width - 6) / 3,
            height: (frame.height - 6) / 2
        )

        self.outSize = outSize
        self.itemSize = calculatedItemSize
        self.pickedBlock = pickedBlock
        self._viewModel = StateObject(wrappedValue: PhotoPickerViewModel(
            itemSize: calculatedItemSize,
            outSize: outSize
        ))
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(
                rows: [
                    GridItem(.flexible(), spacing: 2),
                    GridItem(.flexible(), spacing: 2)
                ],
                spacing: 1
            ) {
                ForEach(viewModel.photoAssets, id: \.localIdentifier) { asset in
                    PhotoCell(
                        asset: asset,
                        itemSize: itemSize,
                        photoPicker: viewModel.photoPicker
                    )
                    .onTapGesture {
                        viewModel.selectPhoto(asset: asset) { image in
                            pickedBlock(image)
                        }
                    }
                }
            }
            .padding(2)
        }
        .background(Color.white)
        .onAppear {
            viewModel.loadPhotos()
        }
    }
}

// MARK: - PhotoPickerViewModel

class PhotoPickerViewModel: ObservableObject {
    @Published var photoAssets: [PHAsset] = []

    let photoPicker: LWPhotoPicker
    let itemSize: CGSize
    let outSize: CGSize
    private let imageCache = NSCache<NSString, UIImage>()

    init(itemSize: CGSize, outSize: CGSize) {
        self.itemSize = itemSize
        self.outSize = outSize
        self.photoPicker = LWPhotoPicker()
    }

    func loadPhotos() {
        photoAssets = photoPicker.getAllAssets(inPhotoAlbum: false)
    }

    func selectPhoto(asset: PHAsset, completion: @escaping (UIImage) -> Void) {
        let cacheKey = "keyboard_\(asset.localIdentifier)" as NSString

        if let cachedImage = imageCache.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        }

        var targetSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        )

        if outSize.width > 0 && outSize.height > 0 {
            targetSize = outSize
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.photoPicker.requestImage(
                for: asset,
                size: targetSize,
                synchronous: false
            ) { image, info in
                guard let image = image else { return }

                DispatchQueue.main.async {
                    self?.imageCache.setObject(image, forKey: cacheKey)
                    completion(image)
                }
            }
        }
    }
}

// MARK: - PhotoCell

struct PhotoCell: View {
    let asset: PHAsset
    let itemSize: CGSize
    let photoPicker: LWPhotoPicker

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: itemSize.width, height: itemSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            } else {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: itemSize.width, height: itemSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        let scale = UIScreen.main.scale
        let size = CGSize(
            width: itemSize.width * scale,
            height: itemSize.height * scale
        )

        photoPicker.requestImage(
            for: asset,
            size: size,
            synchronous: false
        ) { loadedImage, info in
            DispatchQueue.main.async {
                self.image = loadedImage
            }
        }
    }
}

// MARK: - UIKit Bridge (for compatibility)

/// UIKit wrapper for LWPhotoPickerView (maintains compatibility with Objective-C code)
public class LWPhotoPickerUIView: UIView {
    private var hostingController: UIHostingController<LWPhotoPickerView>?

    public var itemSize: CGSize = .zero
    public var blurRatio: CGFloat = 10
    public var photoPicker: LWPhotoPicker?
    public var photoAssets: [PHAsset]?

    public static func photoPicker(
        withFrame frame: CGRect,
        outSize: CGSize,
        pickedBlock: @escaping (UIImage) -> Void
    ) -> LWPhotoPickerUIView {
        let view = LWPhotoPickerUIView(frame: frame)
        view.setupSwiftUIView(frame: frame, outSize: outSize, pickedBlock: pickedBlock)
        return view
    }

    private func setupSwiftUIView(
        frame: CGRect,
        outSize: CGSize,
        pickedBlock: @escaping (UIImage) -> Void
    ) {
        let swiftUIView = LWPhotoPickerView(
            frame: frame,
            outSize: outSize,
            pickedBlock: pickedBlock
        )

        let hostingController = UIHostingController(rootView: swiftUIView)
        self.hostingController = hostingController

        if let hostView = hostingController.view {
            hostView.backgroundColor = .white
            hostView.frame = bounds
            hostView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(hostView)
        }
    }
}

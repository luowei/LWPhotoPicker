//
// LWAspectPhotoPickerView.swift
// LWPhotoPicker
//
// Created by luowei on 2019/5/7.
// Swift/SwiftUI version
//

import SwiftUI
import Photos

// MARK: - LWAspectPhotoPickerView (SwiftUI)

/// SwiftUI photo picker view that preserves aspect ratio
public struct LWAspectPhotoPickerView: View {
    @StateObject private var viewModel: AspectPhotoPickerViewModel

    private let pickedBlock: (UIImage) -> Void

    public init(
        size: CGSize,
        pickedBlock: @escaping (UIImage) -> Void
    ) {
        self.pickedBlock = pickedBlock
        self._viewModel = StateObject(wrappedValue: AspectPhotoPickerViewModel(outSize: size))
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 2) {
                ForEach(viewModel.assetList, id: \.localIdentifier) { asset in
                    AspectPhotoCell(
                        asset: asset,
                        photoPicker: viewModel.photoPicker,
                        cellHeight: viewModel.cellHeight
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
        .frame(height: 256)
        .background(Color.white)
        .onAppear {
            viewModel.loadPhotos()
        }
    }
}

// MARK: - AspectPhotoPickerViewModel

class AspectPhotoPickerViewModel: ObservableObject {
    @Published var assetList: [PHAsset] = []

    let photoPicker: LWPhotoPicker
    let outSize: CGSize
    let cellHeight: CGFloat

    init(outSize: CGSize) {
        self.outSize = outSize
        self.photoPicker = LWPhotoPicker()
        // Calculate cell height: (256 - 2*3) / 2 = 125
        self.cellHeight = (256 - 2 * 3) / 2
    }

    func loadPhotos() {
        assetList = photoPicker.getAllAssets(inPhotoAlbum: false)
    }

    func selectPhoto(asset: PHAsset, completion: @escaping (UIImage) -> Void) {
        // Calculate output size
        var targetOutSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        )

        if outSize.width > 0 && outSize.height > 0 {
            targetOutSize = outSize
        }

        let screenScale = UIScreen.main.scale
        let assetScale = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
        let drawViewScale = targetOutSize.width / targetOutSize.height

        var size = CGSize(
            width: targetOutSize.height * assetScale * screenScale,
            height: targetOutSize.height * screenScale
        )

        if drawViewScale > assetScale {
            size = CGSize(
                width: targetOutSize.width * screenScale,
                height: targetOutSize.width / assetScale * screenScale
            )
        }

        photoPicker.requestImage(
            for: asset,
            size: size,
            synchronous: false
        ) { image, info in
            guard let image = image else { return }

            DispatchQueue.main.async {
                let imgSize = CGSize(
                    width: targetOutSize.width * screenScale,
                    height: targetOutSize.height * screenScale
                )
                let croppedImage = self.cropImage(image, centerSquareSize: imgSize)
                completion(croppedImage)
            }
        }
    }

    // MARK: - Image Cropping

    /// Crop image to center square of specified size
    private func cropImage(_ image: UIImage, centerSquareSize size: CGSize) -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        let refWidth = CGFloat(cgImage.width)
        let refHeight = CGFloat(cgImage.height)

        let x = (refWidth - size.width) / 2.0
        let y = (refHeight - size.height) / 2.0

        let cropRect = CGRect(x: x, y: y, width: size.width, height: size.height)

        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return image }

        return UIImage(
            cgImage: croppedCGImage,
            scale: 0.0,
            orientation: image.imageOrientation
        )
    }
}

// MARK: - AspectPhotoCell

struct AspectPhotoCell: View {
    let asset: PHAsset
    let photoPicker: LWPhotoPicker
    let cellHeight: CGFloat

    @State private var image: UIImage?

    private var cellSize: CGSize {
        let width = CGFloat(asset.pixelWidth)
        let height = CGFloat(asset.pixelHeight)
        let scale = width / height
        return CGSize(width: cellHeight * scale, height: cellHeight)
    }

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cellSize.width, height: cellSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.white, lineWidth: 1)
                    )
            } else {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: cellSize.width, height: cellSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.white, lineWidth: 1)
                    )
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        let scale = UIScreen.main.scale
        let size = CGSize(
            width: cellSize.width * scale,
            height: cellSize.height * scale
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

/// UIKit wrapper for LWAspectPhotoPickerView (maintains compatibility with Objective-C code)
public class LWAspectPhotoPickerUIView: UIView {
    private var hostingController: UIHostingController<LWAspectPhotoPickerView>?

    public var assetList: [PHAsset]?
    public var photoPicker: LWPhotoPicker?

    public static func pickerPhoto(
        withSize size: CGSize,
        pickedBlock: @escaping (UIImage) -> Void
    ) -> LWAspectPhotoPickerUIView {
        let view = LWAspectPhotoPickerUIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: 256
            )
        )
        view.setupSwiftUIView(size: size, pickedBlock: pickedBlock)
        return view
    }

    public init(frame: CGRect, withPhotoPicker photoPicker: LWPhotoPicker) {
        super.init(frame: frame)
        self.photoPicker = photoPicker
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupSwiftUIView(
        size: CGSize,
        pickedBlock: @escaping (UIImage) -> Void
    ) {
        let swiftUIView = LWAspectPhotoPickerView(
            size: size,
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

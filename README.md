# LWPhotoPicker

[![CI Status](https://img.shields.io/travis/luowei/LWPhotoPicker.svg?style=flat)](https://travis-ci.org/luowei/LWPhotoPicker)
[![Version](https://img.shields.io/cocoapods/v/LWPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/LWPhotoPicker)
[![License](https://img.shields.io/cocoapods/l/LWPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/LWPhotoPicker)
[![Platform](https://img.shields.io/cocoapods/p/LWPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/LWPhotoPicker)

[English](./README.md) | [中文版](./README_ZH.md)

---

## Overview

**LWPhotoPicker** is a powerful and flexible iOS photo picker library built on the Photos framework. It provides two distinct picker modes for different use cases, with built-in high-performance caching and comprehensive photo library management capabilities.

### Key Features

- **Dual Picker Modes**
  - Fixed aspect ratio picker for consistent grid layouts
  - Aspect-preserving picker that maintains original photo dimensions
- **High-Performance Caching** - YYCache-based disk caching for optimal performance
- **iCloud Integration** - Seamless support for iCloud Photo Library with automatic downloading
- **Album Management** - Create custom albums and save photos programmatically
- **Smart Filtering** - Automatically excludes videos and recently deleted items
- **Flexible Configuration** - Customizable output sizes and sorting options
- **Block-Based API** - Simple callback interface for easy integration
- **Auto Layout Support** - Built-in Masonry integration for constraint-based layouts

### What's Inside

- Two ready-to-use picker view components (`LWPhotoPickerView`, `LWAspectPhotoPickerView`)
- Core photo library management class (`LWPhotoPicker`)
- Photo metadata access and iCloud status checking
- Batch photo size calculation utilities
- Custom album creation and management

## Requirements

- iOS 8.0 or later
- Xcode 8.0 or later
- Photos framework
- Dependencies: Masonry, YYCache

## Installation

### CocoaPods

LWPhotoPicker is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'LWPhotoPicker'
```

Then run:

```bash
pod install
```

### Carthage

Add the following to your `Cartfile`:

```
github "luowei/LWPhotoPicker"
```

Then run:

```bash
carthage update --platform iOS
```

---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [Privacy Permissions](#privacy-permissions)
  - [Quick Start](#quick-start)
  - [Picker Modes](#picker-modes)
  - [Core LWPhotoPicker Class](#core-lwphotopicker-class)
  - [Image Caching](#image-caching)
  - [Advanced Configuration](#advanced-configuration)
- [API Documentation](#api-documentation)
- [Architecture](#architecture)
- [Example Project](#example-project)
- [Dependencies](#dependencies)
- [Author](#author)
- [License](#license)
- [Contributing](#contributing)

---

## Usage

### Privacy Permissions

**Important:** Before using LWPhotoPicker, you must add photo library access permissions to your `Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select photos</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need permission to save photos to your library</string>
```

### Quick Start

Import the necessary headers:

```objective-c
#import <LWPhotoPicker/LWPhotoPickerView.h>
#import <LWPhotoPicker/LWAspectPhotoPickerView.h>
#import <LWPhotoPicker/LWPhotoPicker.h>
```

### Picker Modes

LWPhotoPicker provides two different picker view modes optimized for different use cases:

#### 1. Fixed Aspect Ratio Picker (LWPhotoPickerView)

This mode displays photos in a consistent grid layout where all thumbnails have the same size. The selected photo is resized to match your specified output dimensions.

**Use cases:** Profile picture selection, fixed-size image galleries, thumbnail grids

```objective-c
// Create a photo picker with fixed output size
CGRect frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 256);
CGSize outputSize = CGSizeMake(800, 600); // Output size for selected image

LWPhotoPickerView *pickerView = [LWPhotoPickerView photoPickerWithFrame:frame
                                                                 outSize:outputSize
                                                             pickedBlock:^(UIImage *image) {
    if (!image) {
        return;
    }
    // Use the selected image
    NSLog(@"Selected image size: %@", NSStringFromCGSize(image.size));
    self.imageView.image = image;
    [pickerView removeFromSuperview];
}];

[self.view addSubview:pickerView];

// Layout with Masonry
[pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.bottom.equalTo(self.view);
    make.height.mas_equalTo(256);
}];
```

#### 2. Aspect-Preserving Picker (LWAspectPhotoPickerView)

This mode preserves the original aspect ratio of photos. Thumbnails are displayed with varying heights to match their natural proportions, creating a more natural browsing experience.

**Use cases:** Photo galleries, image browsers, content that requires maintaining original aspect ratios

```objective-c
// Create an aspect-preserving photo picker
CGSize outputSize = CGSizeMake(1024, 1024); // Maximum output size

LWAspectPhotoPickerView *pickerView = [LWAspectPhotoPickerView pickerPhotoWithSize:outputSize
                                                                        pickedBlock:^(UIImage *image) {
    if (!image) {
        return;
    }
    // Use the selected image (aspect ratio preserved)
    NSLog(@"Selected image: %@", image);
    self.imageView.image = image;
    [pickerView removeFromSuperview];
}];

[self.view addSubview:pickerView];

// Layout with Masonry
[pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.bottom.equalTo(self.view);
    make.height.mas_equalTo(256);
}];
```

### Core LWPhotoPicker Class

The `LWPhotoPicker` class provides comprehensive photo library access and management functionality. Use it when you need more control than the picker views provide.

#### Get All Photo Albums

```objective-c
LWPhotoPicker *photoPicker = [[LWPhotoPicker alloc] init];
NSArray<LWPhotoAblumList *> *albums = [photoPicker getPhotoAblumList];

for (LWPhotoAblumList *album in albums) {
    NSLog(@"Album: %@, Count: %ld", album.title, album.count);
    // album.headImageAsset - First image in album
    // album.assetCollection - PHAssetCollection for accessing photos
}
```

#### Get Photos from Specific Album

```objective-c
// Get all photos sorted by creation date
NSArray<PHAsset *> *assets = [photoPicker getAllAssetInPhotoAblumWithAscending:NO];

// Get photos from specific album
PHAssetCollection *collection = album.assetCollection;
NSArray<PHAsset *> *albumAssets = [photoPicker getAssetsInAssetCollection:collection
                                                               ascending:NO];
```

#### Request Image from Asset

```objective-c
// Request image with specific size
CGSize targetSize = CGSizeMake(300, 300);
[photoPicker requestImageForAsset:asset
                             size:targetSize
                      synchronous:NO
                       completion:^(UIImage *image, NSDictionary *info) {
    // Use the image
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
    });
}];
```

#### Request Image Data with Compression

```objective-c
// Request image data with scale factor
[photoPicker requestImageForAsset:asset
                            scale:1.0
                       resizeMode:PHImageRequestOptionsResizeModeExact
                       completion:^(UIImage *image) {
    // Use the compressed image
    self.imageView.image = image;
}];
```

#### Save Image to Custom Album

```objective-c
UIImage *imageToSave = /* your image */;
[photoPicker saveImageToAblum:imageToSave completion:^(BOOL success, PHAsset *asset) {
    if (success) {
        NSLog(@"Image saved successfully");
    } else {
        NSLog(@"Failed to save image");
    }
}];
```

#### Check Photo Storage Location

```objective-c
// Check if photo is stored locally or needs to be downloaded from iCloud
BOOL isLocal = [photoPicker judgeAssetisInLocalAblum:asset];
if (isLocal) {
    NSLog(@"Photo is available locally");
} else {
    NSLog(@"Photo needs to be downloaded from iCloud");
}
```

#### Calculate Total Size of Photos

```objective-c
NSArray<LWPhotoModel *> *photoModels = /* your photo models */;
[photoPicker getPhotosBytesWithArray:photoModels completion:^(NSString *photosBytes) {
    NSLog(@"Total size: %@", photosBytes); // e.g., "15.3M", "256K", "1024B"
}];
```

### Image Caching

LWPhotoPickerView includes built-in disk caching using YYCache to improve performance:

- Thumbnail images are automatically cached when displayed in the picker
- Full-resolution images are cached after selection
- Cache is stored in the temporary directory and managed automatically
- Cache keys are based on photo asset identifiers

The caching mechanism works transparently:

```objective-c
// Caching is automatic - no additional code needed
// First access: loads from photo library
// Subsequent access: loads from cache (much faster)
```

### Advanced Configuration

#### Customize Picker Appearance

```objective-c
LWPhotoPickerView *pickerView = [LWPhotoPickerView photoPickerWithFrame:frame
                                                                 outSize:outSize
                                                             pickedBlock:pickedBlock];

// Customize item size
pickerView.itemSize = CGSizeMake(100, 100);

// Customize blur ratio for effects
pickerView.blurRatio = 10;

// Access and modify photo assets
pickerView.photoAssets = customAssetArray;
```

#### Working with PHAsset

```objective-c
// Access photo metadata
PHAsset *asset = photoAssets[0];
NSLog(@"Creation Date: %@", asset.creationDate);
NSLog(@"Pixel Width: %ld, Height: %ld", asset.pixelWidth, asset.pixelHeight);
NSLog(@"Media Type: %ld", asset.mediaType);
NSLog(@"Duration: %f", asset.duration);
```

---

## API Documentation

### LWPhotoPickerView

A UICollectionView-based photo picker with fixed aspect ratio cropping.

**Class Methods:**

```objective-c
+ (instancetype)photoPickerWithFrame:(CGRect)frame
                             outSize:(CGSize)outSize
                         pickedBlock:(void (^)(UIImage *image))pickedBlock;
```

Creates and returns a photo picker instance.

- **Parameters:**
  - `frame`: The frame rectangle for the picker view
  - `outSize`: The desired output size for selected images
  - `pickedBlock`: Callback block invoked when user selects a photo
- **Returns:** Configured picker view instance

**Properties:**

- `@property (nonatomic, assign) CGSize itemSize` - Size of each photo cell in the grid
- `@property (nonatomic, assign) CGFloat blurRatio` - Blur effect intensity (default: 10)
- `@property (nonatomic, strong) LWPhotoPicker *photoPicker` - Internal photo picker instance
- `@property (nonatomic, strong) NSArray<PHAsset *> *photoAssets` - Array of photo assets to display

---

### LWAspectPhotoPickerView

A UICollectionView-based photo picker that preserves aspect ratios.

**Class Methods:**

```objective-c
+ (instancetype)pickerPhotoWithSize:(CGSize)size
                        pickedBlock:(void (^)(UIImage *image))pickedBlock;
```

Creates and returns an aspect-preserving photo picker instance.

- **Parameters:**
  - `size`: The maximum output size for selected images
  - `pickedBlock`: Callback block invoked when user selects a photo
- **Returns:** Configured picker view instance

**Properties:**

- `@property (nonatomic, strong) NSArray<PHAsset *> *assetList` - Array of photo assets to display
- `@property (nonatomic, strong) LWPhotoPicker *photoPicker` - Internal photo picker instance

---

### LWPhotoPicker

Core class providing photo library access and management.

**Photo Library Access:**

```objective-c
- (NSArray<LWPhotoAblumList *> *)getPhotoAblumList;
```

Returns all photo albums (smart albums and user albums), excluding videos and recently deleted.

```objective-c
- (NSArray<PHAsset *> *)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending;
```

Returns all photos sorted by creation date.

```objective-c
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection
                                         ascending:(BOOL)ascending;
```

Returns photos from a specific album.

**Image Requests:**

```objective-c
- (void)requestImageForAsset:(PHAsset *)asset
                        size:(CGSize)size
                 synchronous:(BOOL)synchronous
                  completion:(void (^)(UIImage *image, NSDictionary *info))completion;
```

Requests an image with specific size from a photo asset.

```objective-c
- (void)requestImageForAsset:(PHAsset *)asset
                       scale:(CGFloat)scale
                  resizeMode:(PHImageRequestOptionsResizeMode)resizeMode
                  completion:(void (^)(UIImage *image))completion;
```

Requests high-quality image with scale factor and resize mode.

**Album Management:**

```objective-c
- (void)saveImageToAblum:(UIImage *)image
              completion:(void (^)(BOOL success, PHAsset *asset))completion;
```

Saves an image to the photo library.

**Utilities:**

```objective-c
- (BOOL)judgeAssetisInLocalAblum:(PHAsset *)asset;
```

Checks if a photo is stored locally or needs to be downloaded from iCloud.

```objective-c
- (void)getPhotosBytesWithArray:(NSArray<LWPhotoModel *> *)photos
                     completion:(void (^)(NSString *photosBytes))completion;
```

Calculates the total size of multiple photos (returns formatted string like "15.3M").

---

### LWPhotoAblumList

Model class representing a photo album.

**Properties:**

- `@property (nonatomic, copy) NSString *title` - Album name
- `@property (nonatomic, assign) NSInteger count` - Number of photos in album
- `@property (nonatomic, strong) PHAsset *headImageAsset` - First photo in album (for cover)
- `@property (nonatomic, strong) PHAssetCollection *assetCollection` - PHAssetCollection for accessing photos

---

### LWPhotoModel

Model class wrapping a PHAsset.

**Properties:**

- `@property (nonatomic, strong) PHAsset *asset` - The underlying PHAsset
- `@property (nonatomic, copy) NSString *localIdentifier` - Unique local identifier

---

## Example Project

To run the example project:

```bash
# 1. Clone the repository
git clone https://github.com/luowei/LWPhotoPicker.git
cd LWPhotoPicker

# 2. Navigate to the Example directory
cd Example

# 3. Install dependencies
pod install

# 4. Open the workspace
open LWPhotoPicker.xcworkspace
```

The example project demonstrates:
- Both picker modes in action
- Photo library browsing
- Custom album creation
- Photo saving functionality
- iCloud photo handling

---

## Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────┐
│                  Picker Views Layer                  │
├─────────────────────────────────────────────────────┤
│  LWPhotoPickerView  │  LWAspectPhotoPickerView     │
│  (Fixed Layout)     │  (Aspect Preserving)         │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
         ┌─────────────────────┐
         │   LWPhotoPicker     │  ◄─── Core Photo Management
         │   (Core Class)      │
         └─────────┬───────────┘
                   │
         ┌─────────┴──────────┐
         │                    │
         ▼                    ▼
   ┌──────────┐         ┌──────────┐
   │ YYCache  │         │ Photos   │
   │ (Disk)   │         │Framework │
   └──────────┘         └──────────┘
```

### Main Components

| Component | Type | Purpose |
|-----------|------|---------|
| **LWPhotoPickerView** | UICollectionView | Fixed aspect ratio picker with consistent grid layout |
| **LWAspectPhotoPickerView** | UICollectionView | Aspect-preserving picker with dynamic cell heights |
| **LWPhotoPicker** | Core Class | Photo library access, album management, image requests |
| **LWPhotoAblumList** | Model | Represents photo album metadata and assets |
| **LWPhotoModel** | Model | Wraps PHAsset with local identifier for caching |
| **LWPhotoCollectionCell** | UICollectionViewCell | Custom cell for displaying photo thumbnails |

### Caching Strategy

LWPhotoPicker implements a sophisticated caching mechanism using [YYCache](https://github.com/ibireme/YYCache):

- **Two-Tier Caching:**
  - Thumbnail cache for picker display (optimized for scrolling performance)
  - Full-resolution cache for selected images (reduces re-processing)

- **Cache Keys:** Based on PHAsset's `localIdentifier` for reliable lookup

- **Automatic Management:**
  - Cache stored in temporary directory
  - Transparent loading (checks cache first, then photo library)
  - Memory-efficient disk storage

- **iCloud Support:**
  - Progressive loading: preview first, then full quality
  - Automatic download with network permission
  - Cache updates when higher quality becomes available

### Design Patterns

- **Factory Pattern:** Class methods for creating pre-configured instances
- **Block-Based Callbacks:** Simple async API without delegate protocols
- **Model-View Separation:** Clean separation between data models and UI components
- **Dependency Injection:** Photo picker instance can be customized or replaced

---

## Dependencies

LWPhotoPicker relies on the following libraries:

- [**Masonry**](https://github.com/SnapKit/Masonry) - Declarative Auto Layout framework for cleaner constraint code
- [**YYCache**](https://github.com/ibireme/YYCache) - High-performance cache framework for disk and memory caching

These dependencies are automatically managed through CocoaPods or Carthage.

---

## Best Practices

### Performance Tips

1. **Reuse Picker Instances** - Create picker views once and reuse them to avoid repeated initialization
2. **Optimize Output Size** - Choose reasonable output sizes to balance quality and performance
3. **Async Loading** - Always use asynchronous image requests (`synchronous:NO`) to avoid blocking UI
4. **Cache Awareness** - Let the built-in cache handle thumbnails automatically

### Error Handling

```objective-c
// Always check for nil images
LWPhotoPickerView *picker = [LWPhotoPickerView photoPickerWithFrame:frame
                                                             outSize:outSize
                                                         pickedBlock:^(UIImage *image) {
    if (!image) {
        NSLog(@"Failed to load image");
        return;
    }

    // Proceed with valid image
    self.imageView.image = image;
}];
```

### Permission Handling

```objective-c
#import <Photos/Photos.h>

// Check authorization status before accessing photos
PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];

if (status == PHAuthorizationStatusNotDetermined) {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            // Create and show picker
        }
    }];
} else if (status == PHAuthorizationStatusAuthorized) {
    // Create and show picker
} else {
    // Show alert directing user to Settings
}
```

### Thread Safety

```objective-c
// Always update UI on main thread
[photoPicker requestImageForAsset:asset
                             size:targetSize
                      synchronous:NO
                       completion:^(UIImage *image, NSDictionary *info) {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
    });
}];
```

---

## Troubleshooting

### Common Issues

**Q: Photos load slowly or don't appear**

A: This typically occurs when photos are stored in iCloud. Ensure:
- Device has network connectivity
- iCloud Photo Library is enabled
- `PHImageRequestOptions.networkAccessAllowed = YES`

**Q: App crashes with "This app has crashed because it attempted to access privacy-sensitive data"**

A: You haven't added required privacy keys to `Info.plist`. Add:
- `NSPhotoLibraryUsageDescription`
- `NSPhotoLibraryAddUsageDescription`

**Q: Selected image quality is poor**

A: Increase the `outSize` parameter when creating the picker. The output size directly affects image quality.

**Q: Picker view doesn't appear or is empty**

A: Check photo library authorization status. The picker requires `PHAuthorizationStatusAuthorized` to access photos.

**Q: Memory warnings when browsing many photos**

A: This is normal for large photo libraries. The built-in cache helps, but iOS will automatically free memory as needed. Consider:
- Reducing output size for thumbnails
- Implementing pagination if building custom UI
- Letting the system handle memory warnings naturally

---

## Changelog

### Version 1.0.0
- Initial release
- Fixed aspect ratio picker mode
- Aspect-preserving picker mode
- YYCache integration for performance
- iCloud Photo Library support
- Album management and photo saving
- Comprehensive photo library access API

---

## Author

**Luo Wei**
Email: luowei@wodedata.com

---

## License

LWPhotoPicker is available under the **MIT License**. See the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2019 Luo Wei

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Contributing

Contributions are welcome! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Contribution Guidelines

- Follow the existing code style and conventions
- Add tests for new features when applicable
- Update documentation to reflect changes
- Ensure all tests pass before submitting PR
- Write clear commit messages

### Reporting Issues

When reporting issues, please include:
- iOS version and device model
- Xcode version
- LWPhotoPicker version
- Steps to reproduce the issue
- Expected vs actual behavior
- Any relevant code snippets or screenshots

---

## Links

- **GitHub Repository:** [https://github.com/luowei/LWPhotoPicker](https://github.com/luowei/LWPhotoPicker)
- **CocoaPods:** [https://cocoapods.org/pods/LWPhotoPicker](https://cocoapods.org/pods/LWPhotoPicker)
- **Issue Tracker:** [https://github.com/luowei/LWPhotoPicker/issues](https://github.com/luowei/LWPhotoPicker/issues)

---

<p align="center">Made with ❤️ by <a href="https://github.com/luowei">Luo Wei</a></p>

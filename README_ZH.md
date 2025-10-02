# LWPhotoPicker

[![CI Status](https://img.shields.io/travis/luowei/LWPhotoPicker.svg?style=flat)](https://travis-ci.org/luowei/LWPhotoPicker)
[![Version](https://img.shields.io/cocoapods/v/LWPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/LWPhotoPicker)
[![License](https://img.shields.io/cocoapods/l/LWPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/LWPhotoPicker)
[![Platform](https://img.shields.io/cocoapods/p/LWPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/LWPhotoPicker)

## 简介

LWPhotoPicker 是一个轻量级的 iOS 照片选择器库，支持从系统相册选择照片并提供两种不同的显示模式。该库基于 Photos 框架开发，提供了简洁的 API 和高性能的图片加载机制。

### 主要特性

- 支持两种照片选择视图模式：
  - **固定尺寸模式** (`LWPhotoPickerView`)：以固定的网格尺寸显示照片，适合固定布局场景
  - **保持宽高比模式** (`LWAspectPhotoPickerView`)：保持照片原始宽高比显示，适合图片浏览场景
- 集成 YYCache 实现高效的磁盘缓存，避免重复加载
- 支持 iCloud 照片库，自动从云端下载照片
- 提供完整的相册管理功能
- 支持照片保存到自定义相册
- 流畅的横向滚动浏览体验
- 支持 CocoaPods 和 Carthage 安装

## 系统要求

- iOS 8.0 或更高版本
- Xcode 9.0 或更高版本

## 安装

### CocoaPods

[CocoaPods](https://cocoapods.org) 是 Cocoa 项目的依赖管理器。在您的 `Podfile` 中添加以下内容：

```ruby
pod 'LWPhotoPicker'
```

然后运行：

```bash
pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) 是一个去中心化的依赖管理器。在您的 `Cartfile` 中添加以下内容：

```ruby
github "luowei/LWPhotoPicker"
```

然后运行：

```bash
carthage update
```

## 使用方法

### 基础配置

首先，在您的 `Info.plist` 文件中添加照片库访问权限说明：

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问您的照片库以选择照片</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>需要访问您的照片库以保存照片</string>
```

### 示例 1：使用固定尺寸照片选择器 (LWPhotoPickerView)

固定尺寸模式以网格形式展示照片，所有照片单元格大小一致。

```objective-c
#import "LWPhotoPickerView.h"

// 创建照片选择器视图
CGRect frame = CGRectMake(0, 0, 320, 200);
CGSize outSize = CGSizeMake(800, 600); // 选中照片的输出尺寸

LWPhotoPickerView *photoPickerView = [LWPhotoPickerView photoPickerWithFrame:frame
                                                                      outSize:outSize
                                                                  pickedBlock:^(UIImage *image) {
    // 用户选择照片后的回调
    NSLog(@"选中照片尺寸: %@", NSStringFromCGSize(image.size));
    // 在这里处理选中的照片
}];

// 添加到父视图
[self.view addSubview:photoPickerView];

// 使用 Masonry 进行约束布局（可选）
[photoPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(20, 0, 0, 0));
}];
```

### 示例 2：使用保持宽高比照片选择器 (LWAspectPhotoPickerView)

保持宽高比模式会根据照片原始尺寸动态调整单元格大小，提供更自然的浏览体验。

```objective-c
#import "LWAspectPhotoPickerView.h"

// 创建保持宽高比的照片选择器
CGSize outSize = CGSizeMake(1024, 768); // 选中照片的输出尺寸

LWAspectPhotoPickerView *aspectPickerView = [LWAspectPhotoPickerView pickerPhotoWithSize:outSize
                                                                              pickedBlock:^(UIImage *image) {
    // 用户选择照片后的回调
    NSLog(@"选中照片: %@", image);
    // 在这里处理选中的照片
}];

// 添加到父视图
[self.view addSubview:aspectPickerView];
```

### 示例 3：使用照片管理工具类 (LWPhotoPicker)

`LWPhotoPicker` 提供了丰富的照片管理功能。

```objective-c
#import "LWPhotoPicker.h"

LWPhotoPicker *photoPicker = [[LWPhotoPicker alloc] init];

// 1. 保存图片到系统相册
UIImage *imageToSave = [UIImage imageNamed:@"example"];
[photoPicker saveImageToAblum:imageToSave completion:^(BOOL success, PHAsset *asset) {
    if (success) {
        NSLog(@"照片保存成功");
    } else {
        NSLog(@"照片保存失败");
    }
}];

// 2. 获取所有相册列表
NSArray<LWPhotoAblumList *> *albumList = [photoPicker getPhotoAblumList];
for (LWPhotoAblumList *album in albumList) {
    NSLog(@"相册名: %@, 照片数量: %ld", album.title, (long)album.count);
}

// 3. 获取所有照片资源（按时间降序）
NSArray<PHAsset *> *allAssets = [photoPicker getAllAssetInPhotoAblumWithAscending:NO];
NSLog(@"总共有 %ld 张照片", (long)allAssets.count);

// 4. 获取指定相册内的照片
LWPhotoAblumList *firstAlbum = albumList.firstObject;
NSArray<PHAsset *> *assetsInAlbum = [photoPicker getAssetsInAssetCollection:firstAlbum.assetCollection
                                                                   ascending:YES];

// 5. 请求照片图像
PHAsset *asset = allAssets.firstObject;
CGSize targetSize = CGSizeMake(300, 300);
[photoPicker requestImageForAsset:asset
                             size:targetSize
                      synchronous:NO
                       completion:^(UIImage *image, NSDictionary *info) {
    // 获取到照片后的处理
    NSLog(@"获取到照片: %@", image);
}];

// 6. 判断照片是否存储在本地
BOOL isLocal = [photoPicker judgeAssetisInLocalAblum:asset];
if (isLocal) {
    NSLog(@"照片已存储在本地");
} else {
    NSLog(@"照片存储在 iCloud，需要下载");
}

// 7. 获取照片数组的总大小
NSArray<LWPhotoModel *> *photoModels = @[/* 照片模型数组 */];
[photoPicker getPhotosBytesWithArray:photoModels completion:^(NSString *photosBytes) {
    NSLog(@"照片总大小: %@", photosBytes);
}];
```

## 核心类说明

### LWPhotoPickerView

固定尺寸照片选择器视图，继承自 `UICollectionView`。

#### 主要属性

- `itemSize`：照片单元格尺寸
- `blurRatio`：模糊比率（默认值：10）
- `photoPicker`：照片管理器实例
- `photoAssets`：照片资源数组

#### 主要方法

```objective-c
+ (instancetype)photoPickerWithFrame:(CGRect)frame
                             outSize:(CGSize)outSize
                         pickedBlock:(void (^)(UIImage *))pickedBlock;
```

创建照片选择器实例。

**参数说明：**
- `frame`：视图框架
- `outSize`：选中照片的输出尺寸
- `pickedBlock`：照片选择回调

### LWAspectPhotoPickerView

保持宽高比照片选择器视图，继承自 `UICollectionView`。

#### 主要属性

- `assetList`：照片资源列表
- `photoPicker`：照片管理器实例

#### 主要方法

```objective-c
+ (instancetype)pickerPhotoWithSize:(CGSize)size
                        pickedBlock:(void (^)(UIImage *))pickedBlock;
```

创建保持宽高比的照片选择器实例。

**参数说明：**
- `size`：选中照片的输出尺寸
- `pickedBlock`：照片选择回调

### LWPhotoPicker

照片管理核心类，提供照片库访问和操作功能。

#### 主要方法

```objective-c
// 保存图片到系统相册
- (void)saveImageToAblum:(UIImage *)image
              completion:(void (^)(BOOL success, PHAsset *asset))completion;

// 获取所有相册列表
- (NSArray<LWPhotoAblumList *> *)getPhotoAblumList;

// 获取所有照片资源
- (NSArray<PHAsset *> *)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending;

// 获取指定相册内的照片
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection
                                         ascending:(BOOL)ascending;

// 请求照片图像
- (void)requestImageForAsset:(PHAsset *)asset
                        size:(CGSize)size
                 synchronous:(BOOL)synchronous
                  completion:(void (^)(UIImage *image, NSDictionary *info))completion;

// 获取高质量照片
- (void)requestImageForAsset:(PHAsset *)asset
                       scale:(CGFloat)scale
                  resizeMode:(PHImageRequestOptionsResizeMode)resizeMode
                  completion:(void (^)(UIImage *image))completion;

// 获取照片数组的字节大小
- (void)getPhotosBytesWithArray:(NSArray *)photos
                     completion:(void (^)(NSString *photosBytes))completion;

// 判断照片是否存储在本地
- (BOOL)judgeAssetisInLocalAblum:(PHAsset *)asset;
```

### LWPhotoAblumList

相册信息模型类。

#### 属性

- `title`：相册名称
- `count`：该相册内照片数量
- `headImageAsset`：相册封面图（第一张照片）
- `assetCollection`：相册集对象，用于获取该相册的所有照片

### LWPhotoModel

照片模型类。

#### 属性

- `asset`：PHAsset 对象
- `localIdentifier`：照片的本地唯一标识符

## 高级功能

### 缓存机制

LWPhotoPicker 使用 [YYCache](https://github.com/ibireme/YYCache) 实现磁盘缓存：

- 自动缓存已加载的照片缩略图和原图
- 使用照片的 `localIdentifier` 作为缓存键
- 显著提升照片浏览性能
- 减少内存占用和重复加载

### iCloud 支持

自动处理存储在 iCloud 的照片：

- 自动检测照片是否在本地
- 从 iCloud 自动下载照片
- 支持显示下载进度（通过 `info` 字典）

### 图片质量控制

支持多种图片质量和尺寸控制选项：

- `PHImageRequestOptionsResizeModeExact`：精确控制照片尺寸
- `PHImageRequestOptionsResizeModeFast`：快速加载接近目标尺寸的照片
- 可自定义压缩比例

## 运行示例项目

要运行示例项目，请按照以下步骤：

1. 克隆仓库：

```bash
git clone https://github.com/luowei/LWPhotoPicker.git
cd LWPhotoPicker
```

2. 进入 Example 目录并安装依赖：

```bash
cd Example
pod install
```

3. 打开工作空间：

```bash
open LWPhotoPicker.xcworkspace
```

4. 运行项目查看示例效果

## 依赖库

- [Masonry](https://github.com/SnapKit/Masonry)：用于 Auto Layout 布局
- [YYCache](https://github.com/ibireme/YYCache)：用于高性能缓存

## 注意事项

1. **权限申请**：使用前必须在 Info.plist 中添加照片库访问权限说明
2. **异步加载**：照片加载是异步的，需要在回调中处理 UI 更新
3. **内存管理**：处理大量照片时注意内存使用，建议使用缓存机制
4. **iCloud 照片**：从 iCloud 下载照片可能需要时间，需要考虑网络状态
5. **线程安全**：UI 更新必须在主线程执行

## 常见问题

### Q: 如何自定义照片选择器的外观？

A: `LWPhotoPickerView` 和 `LWAspectPhotoPickerView` 都继承自 `UICollectionView`，可以通过修改 `UICollectionViewFlowLayout` 来自定义布局，或者通过子类化 Cell 来自定义单元格外观。

### Q: 如何限制选择的照片数量？

A: 目前库本身不提供多选功能，每次点击会立即返回选中的照片。如需多选功能，可以在回调中自行实现选择逻辑。

### Q: 如何处理用户拒绝照片访问权限？

A: 在调用任何照片相关功能前，应该检查 `PHPhotoLibrary.authorizationStatus()`，如果用户拒绝授权，应引导用户到设置中开启权限。

### Q: 照片加载很慢怎么办？

A: 这通常是因为照片存储在 iCloud 需要下载。确保 `PHImageRequestOptions` 的 `networkAccessAllowed` 设置为 `YES`，并考虑显示加载指示器。

## 版本历史

### 1.0.0
- 初始版本发布
- 支持固定尺寸照片选择器
- 支持保持宽高比照片选择器
- 集成缓存机制
- 支持 iCloud 照片

## 作者

罗伟 (Luo Wei) - luowei@wodedata.com

## 许可证

LWPhotoPicker 基于 MIT 许可证开源。详见 [LICENSE](LICENSE) 文件。

```
MIT License

Copyright (c) 2019 luowei

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

## 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的改动 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

## 相关链接

- GitHub: https://github.com/luowei/LWPhotoPicker
- CocoaPods: https://cocoapods.org/pods/LWPhotoPicker

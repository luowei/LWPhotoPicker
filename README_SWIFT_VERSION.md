# LWPhotoPicker Swift 版本使用说明

## 概述

`LWPhotoPicker_swift` 是 `LWPhotoPicker` 库的 Swift 子模块，包含了使用 Swift 编写的照片选择器组件。

## 安装

### 使用 Swift 版本

如果你的项目使用 Swift，可以安装 Swift 版本：

```ruby
pod 'LWPhotoPicker_swift'
```

### 使用 Objective-C 版本

如果你的项目使用 Objective-C，可以安装原版本：

```ruby
pod 'LWPhotoPicker'
```

### 同时使用两个版本

如果需要同时使用 Objective-C 和 Swift 版本：

```ruby
pod 'LWPhotoPicker'
pod 'LWPhotoPicker_swift'
```

## Swift 文件列表

本 Swift 子模块包含以下文件：

- `LWPhotoPicker.swift` - 照片选择器主类
- `LWPhotoPickerView.swift` - 照片选择视图（保留宽高比）
- `LWAspectPhotoPickerView.swift` - 固定宽高比照片选择视图

## 特性

- 支持保留宽高比的照片选择
- 支持固定宽高比的照片选择
- Swift 友好的 API
- 基于 Masonry 进行布局
- 使用 YYCache 进行缓存管理

## 依赖

- Masonry
- YYCache

## 版本要求

- iOS 8.0+
- Swift 5.0+

## 许可证

LWPhotoPicker_swift 使用 MIT 许可证。详情请参见 LICENSE 文件。

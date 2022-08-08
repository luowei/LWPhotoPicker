# LWPhotoPicker

[![CI Status](https://img.shields.io/travis/luowei/LWPhotoPicker.svg?style=flat)](https://travis-ci.org/luowei/LWPhotoPicker)
[![Version](https://img.shields.io/cocoapods/v/LWPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/LWPhotoPicker)
[![License](https://img.shields.io/cocoapods/l/LWPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/LWPhotoPicker)
[![Platform](https://img.shields.io/cocoapods/p/LWPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/LWPhotoPicker)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```Objective-C
LWPhotoPickerView *photoPickerView = [LWPhotoPickerView photoPickerWithFrame:skinSettingPopView.bounds];
[skinSettingPopView addSubview:photoPickerView];
photoPickerView.pickerDelegate = self;
[photoPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(skinSettingPopView).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
}];

//in block
[weakSelf.pickerDelegate pickView:(LWPhotoPickerView *)weakSelf didSelectItem:cell];
```

## Requirements

## Installation

LWPhotoPicker is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LWPhotoPicker'
```

**Carthage**
```ruby
github "luowei/LWPhotoPicker"
```

## Author

luowei, luowei@wodedata.com

## License

LWPhotoPicker is available under the MIT license. See the LICENSE file for more info.

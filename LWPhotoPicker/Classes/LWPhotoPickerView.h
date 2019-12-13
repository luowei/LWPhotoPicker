//
//  LWPhotoPickerView.h
//  MyInputMethod
//
//  Created by Luo Wei on 2017/3/4.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LWPhotoCollectionCell;
@class LWPhotoPicker;
@class LWPhotoPickerView;
@class PHAsset;
@class YYDiskCache;


@interface LWPhotoPickerView : UICollectionView<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic) CGSize itemSize;

@property(nonatomic) CGFloat blurRatio;

@property(nonatomic, strong, nullable) LWPhotoPicker *photoPicker;

@property(nonatomic, strong, nullable) NSArray<PHAsset *> *photoAssets;

+(instancetype)photoPickerWithFrame:(CGRect)frame outSize:(CGSize)outSize pickedBlock:(void (^)(UIImage *))pickedBlock;

@end


@interface LWPhotoCollectionCell : UICollectionViewCell

@property(nonatomic, strong, nullable) UIImageView *imageView;

@property(nonatomic, strong, nullable) PHAsset *photoAsset;

@end

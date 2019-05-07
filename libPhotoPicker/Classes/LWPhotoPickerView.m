//
//  LWPhotoPickerView.m
//  MyInputMethod
//
//  Created by Luo Wei on 2017/3/4.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import <Photos/Photos.h>
#import "LWPhotoPickerView.h"
#import "SDImageCache.h"
#import "LWPhotoPicker.h"
#import "Masonry.h"

@interface LWPhotoPickerView ()
@property(nonatomic) CGSize outSize;
@property(nonatomic, copy) void (^pickedBlock)(UIImage *);
@end

@implementation LWPhotoPickerView

+(instancetype)photoPickerWithFrame:(CGRect)frame outSize:(CGSize)outSize pickedBlock:(void (^)(UIImage *))pickedBlock {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 2;
    layout.itemSize = CGSizeMake((CGRectGetWidth(frame)-6)/3, (CGRectGetHeight(frame)-6)/2);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    LWPhotoPickerView *pickerView = [[LWPhotoPickerView alloc] initWithFrame:frame collectionViewLayout:layout];
    pickerView.itemSize = layout.itemSize;
    pickerView.outSize = outSize;
    pickerView.pickedBlock = pickedBlock;
    return pickerView;
}



- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.contentInset = UIEdgeInsetsMake(2, 2, 2, 2);

        self.dataSource = self;
        self.delegate = self;
        self.blurRatio = 10;
        
        [self registerClass:[LWPhotoCollectionCell class] forCellWithReuseIdentifier:@"LWPhotoCollectionCell"];

        [self reloadPhotos];
    }

    return self;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.photoAssets) {
        return self.photoAssets.count;
    } else {
        return 0;
    }
}

- (void)reloadPhotos {

    if(!self.photoPicker){
        self.photoPicker = [[LWPhotoPicker alloc] init];
    }
    
    if(!self.photoAssets){
        self.photoAssets = [self.photoPicker getAllAssetInPhotoAblumWithAscending:NO];
    }

    [self reloadData];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWPhotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LWPhotoCollectionCell" forIndexPath:indexPath];
    cell.imageView.backgroundColor = [UIColor whiteColor];
    if (!self.photoAssets) {
        return cell;
    }

    PHAsset *asset = self.photoAssets[(NSUInteger) indexPath.item];
    NSString *assetIdentifier = asset.localIdentifier;
    cell.photoAsset = asset;

    //从缓存目录找,没有才去相册加载
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    UIImage *image = [imageCache imageFromDiskCacheForKey:assetIdentifier];
    if(image){
        cell.imageView.image = image;
        cell.imageView.highlightedImage = image;
    }else{
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize itemSize = CGSizeMake(self.itemSize.width * scale, self.itemSize.height * scale);

        [self.photoPicker requestImageForAsset:asset size:itemSize synchronous:NO completion:^(UIImage *img, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                cell.imageView.image = img;
                cell.imageView.highlightedImage = image;
                [imageCache storeImage:img forKey:assetIdentifier toDisk:YES completion:nil];
            });
        }];
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LWPhotoCollectionCell *cell = (LWPhotoCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    PDPhotoLibPicker *photoPicker = [[PDPhotoLibPicker alloc] initWithDelegate:self];
//    [photoPicker pictureWithURL:cell.url];

    //UIImage *cellImage = cell.imageView.image;
    PHAsset *asset = cell.photoAsset;
    //从缓存目录找,没有才去相册加载
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    NSString *keyString = [NSString stringWithFormat:@"keybooard_%@", asset.localIdentifier];

    UIImage *image = [imageCache imageFromDiskCacheForKey:keyString];
    if(image){
        if(self.pickedBlock){
            self.pickedBlock(image);
        }

    }else{

        CGSize itemSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        if(self.outSize.width > 0 && self.outSize.height > 0){
            itemSize = self.outSize;
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __weak typeof(self) weakSelf = self;
            [self.photoPicker requestImageForAsset:asset size:itemSize synchronous:NO completion:^(UIImage *img, NSDictionary *info) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                //给cell设置Image
                [[SDImageCache sharedImageCache] storeImage:img forKey:keyString toDisk:YES completion:nil];

                dispatch_async(dispatch_get_main_queue(), ^() {
                    if(strongSelf.pickedBlock){
                        strongSelf.pickedBlock(img);
                    }
                });

            }];
        });

    }

}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
}


@end



@implementation LWPhotoCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.backgroundColor = [UIColor whiteColor];

        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];

        self.imageView.clipsToBounds = YES;
        CALayer *layer = self.imageView.layer;
        layer.cornerRadius = 2.0;
    }

    return self;
}


@end



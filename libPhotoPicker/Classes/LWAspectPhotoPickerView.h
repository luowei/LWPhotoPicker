//
// Created by luowei on 2019/5/7.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class LWPhotoPicker;


@interface LWAspectPhotoPickerView : UICollectionView<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic, strong) NSArray<PHAsset *> * assetList;

@property(nonatomic, strong) LWPhotoPicker *photoPicker;

+ (instancetype)pickerPhotoWithSize:(CGSize)size pickedBlock:(void (^)(UIImage *))pickedBlock;

- (instancetype)initWithFrame:(CGRect)frame withPhotoPicker:(LWPhotoPicker *)photoPicker;


@end



@interface LWAspectSizePhotoCollectionCell : UICollectionViewCell

@property(nonatomic, strong) UIImageView *imageView;

@end

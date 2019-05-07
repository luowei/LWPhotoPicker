//
// Created by luowei on 2019/5/7.
//

#import "LWAspectPhotoPickerView.h"
#import "LWPhotoPicker.h"


@interface LWAspectPhotoPickerView ()
@property(nonatomic, copy) void (^pickedBlock)(UIImage *);
@property(nonatomic) CGSize outSize;
@end

@implementation LWAspectPhotoPickerView {

}

//-(instancetype)pickerPhotoWithSize:(CGSize)outSize


+ (instancetype)pickerPhotoWithSize:(CGSize)outSize pickedBlock:(void (^)(UIImage *))pickedBlock {
    LWPhotoPicker *photoPicker = [[LWPhotoPicker alloc] init];
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 256);
    LWAspectPhotoPickerView *pickerView = [[LWAspectPhotoPickerView alloc] initWithFrame:frame withPhotoPicker:photoPicker];
    pickerView.pickedBlock = pickedBlock;
    pickerView.outSize = outSize;
    return pickerView;
}


- (instancetype)initWithFrame:(CGRect)frame withPhotoPicker:(LWPhotoPicker *)photoPicker{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    layout.minimumLineSpacing = 2;
    layout.minimumInteritemSpacing = 2;

    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        self.scrollEnabled = YES;
        self.bounces = YES;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.scrollsToTop = NO;

        self.photoPicker = photoPicker;

        self.dataSource = self;
        self.delegate = self;

        [self registerClass:[LWAspectSizePhotoCollectionCell class] forCellWithReuseIdentifier:@"PhotoCell"];

    }

    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self reoadPhotos];
}


- (void)reoadPhotos {
    self.assetList = [self.photoPicker getAllAssetInPhotoAblumWithAscending:NO];

    [self reloadData];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWAspectSizePhotoCollectionCell *cell = (LWAspectSizePhotoCollectionCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    __block UIImage *tileImage = nil;
    PHAsset *asset = (PHAsset *) self.assetList[(NSUInteger) indexPath.item];

    __weak typeof(cell) weakCell = cell;
    [self getImageWithAsset:asset completion:^(UIImage *image, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            tileImage = image;
            weakCell.imageView.image = tileImage;
        });
    }];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = self.assetList[indexPath.row];
    return [self getSizeWithAsset:asset];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LWAspectSizePhotoCollectionCell *cell = (LWAspectSizePhotoCollectionCell *) [collectionView cellForItemAtIndexPath:indexPath];

    PHAsset *asset = (PHAsset *) self.assetList[(NSUInteger) indexPath.item];

    //计算Size
    CGSize outSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    if(self.outSize.width > 0 && self.outSize.height > 0){
        outSize = self.outSize;
    }


    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGFloat assetScale = ((CGFloat)asset.pixelWidth) / ((CGFloat)asset.pixelHeight);
    CGFloat drawViewScale = outSize.width / outSize.height;
    CGSize size = CGSizeMake(outSize.height * assetScale  * screenScale, outSize.height * screenScale);
    if((drawViewScale > assetScale)){
        size = CGSizeMake(outSize.width * screenScale , outSize.width / assetScale * screenScale);
    }

    [self.photoPicker requestImageForAsset:asset size:size synchronous:NO completion:^(UIImage *image, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            CGSize imgSize = CGSizeMake(outSize.width * screenScale, outSize.height * screenScale);
            UIImage *cropedImg = [self croppingImage:image centerSquareSize:imgSize];
            if(self.pickedBlock){
                self.pickedBlock(cropedImg);
            }
        });
    }];

}

//截取中间指定大小的区域
- (UIImage *)croppingImage:(UIImage *)image centerSquareSize:(CGSize)size {
    // not equivalent to image.size (which depends on the imageOrientation)!
    CGFloat refWidth = CGImageGetWidth(image.CGImage);
    CGFloat refHeight = CGImageGetHeight(image.CGImage);

    CGFloat x = (CGFloat) ((refWidth - size.width) / 2.0);
    CGFloat y = (CGFloat) ((refHeight - size.height) / 2.0);

    CGRect cropRect = CGRectMake(x, y, size.width, size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);

    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:0.0 orientation:image.imageOrientation];
    CGImageRelease(imageRef);

    return cropped;
}


//获取图片及图片尺寸的相关方法
- (CGSize)getSizeWithAsset:(PHAsset *)asset {
    CGFloat width = (CGFloat) asset.pixelWidth;
    CGFloat height = (CGFloat) asset.pixelHeight;
    CGFloat scale = width / height;

    CGFloat cellHeight = (CGFloat) floor((self.frame.size.height- 2 * 3) / 2 );
    return CGSizeMake(cellHeight * scale, cellHeight);
}

- (void)getImageWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *image, NSDictionary *info))completion {
    CGSize size = [self getSizeWithAsset:asset];
    CGFloat scale = [UIScreen mainScreen].scale;
    size.width *= scale;
    size.height *= scale;
    [self.photoPicker requestImageForAsset:asset size:size synchronous:NO completion:completion];
}

@end



@implementation LWAspectSizePhotoCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:self.imageView];
        self.imageView.userInteractionEnabled = NO;

        self.imageView.layer.borderWidth = 1.0;
        self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.imageView.layer.cornerRadius = 2;
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}


@end

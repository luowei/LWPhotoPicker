//
// Created by Luo Wei on 2017/4/22.
// Copyright (c) 2017 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface LWPhotoAblumList : NSObject

@property (nonatomic, copy) NSString *title; //相册名字
@property (nonatomic, assign) NSInteger count; //该相册内相片数量
@property (nonatomic, strong) PHAsset *headImageAsset; //相册第一张图片缩略图
@property (nonatomic, strong) PHAssetCollection *assetCollection; //相册集，通过该属性获取该相册集下所有照片

@end


@interface LWPhotoPicker : NSObject

//保存图片到系统相册
- (void)saveImageToAblum:(UIImage *)image completion:(void (^)(BOOL suc, PHAsset *asset))completion;

//获取用户所有相册列表
- (NSArray<LWPhotoAblumList *> *)getPhotoAblumList;


//获取相册内所有图片资源，是否按创建时间正序排列 YES,创建时间正（升）序排列; NO,创建时间倒（降）序排列
- (NSArray<PHAsset *> *)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending;


//获取指定相册内的所有图片
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending;


//获取每个Asset对应的图片
- (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size synchronous:(BOOL)synchronous completion:(void (^)(UIImage *image, NSDictionary *info))completion;


//点击确定时，获取每个Asset对应的图片（imageData）
- (void)requestImageForAsset:(PHAsset *)asset scale:(CGFloat)scale resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *image))completion;

//获取数组内图片的字节大小
- (void)getPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *photosBytes))completion;


//判断图片是否存储在本地/或者已经从iCloud上下载到本地
- (BOOL)judgeAssetisInLocalAblum:(PHAsset *)asset ;


@end



@interface LWPhotoModel : NSObject

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, copy) NSString *localIdentifier;

@end
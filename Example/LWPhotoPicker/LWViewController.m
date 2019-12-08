//
//  LWViewController.m
//  LWPhotoPicker
//
//  Created by luowei on 05/07/2019.
//  Copyright (c) 2019 luowei. All rights reserved.
//

#import <LWPhotoPicker/LWAspectPhotoPickerView.h>
#import <Masonry/View+MASAdditions.h>
#import "LWViewController.h"
#import "LWPhotoPickerView.h"

@interface LWViewController ()

@property(nonatomic, strong) UIView *pickerView;
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIButton *leftPickerBtn;
@property(nonatomic, strong) UIButton *rightPickerBtn;
@end

@implementation LWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.imageView = [UIImageView new];
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(60);
        make.width.height.mas_equalTo(200);
    }];
    self.imageView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    self.imageView.layer.cornerRadius = 4;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit; // UIViewContentModeCenter


    self.leftPickerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.leftPickerBtn];
    [self.leftPickerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view).offset(-80);
        make.top.equalTo(self.imageView.mas_bottom).offset(20);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(36);
    }];
    self.leftPickerBtn.backgroundColor = [UIColor orangeColor];
    self.leftPickerBtn.layer.cornerRadius = 8;
    [self.leftPickerBtn setTitle:@"选择照片" forState:UIControlStateNormal];
    [self.leftPickerBtn addTarget:self action:@selector(leftPickerBtnAction) forControlEvents:UIControlEventTouchUpInside];



    self.rightPickerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.rightPickerBtn];
    [self.rightPickerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view).offset(80);
        make.top.equalTo(self.imageView.mas_bottom).offset(20);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(36);
    }];
    self.rightPickerBtn.backgroundColor = [UIColor orangeColor];
    self.rightPickerBtn.layer.cornerRadius = 8;
    [self.rightPickerBtn setTitle:@"选择照片" forState:UIControlStateNormal];
    [self.rightPickerBtn addTarget:self action:@selector(rightPickerBtnAction) forControlEvents:UIControlEventTouchUpInside];

}


- (void)leftPickerBtnAction {
    CGFloat height = 256;
    self.pickerView = [LWAspectPhotoPickerView pickerPhotoWithSize:CGSizeMake(100, 160) pickedBlock:^(UIImage *image){
        self.imageView.image = image;
        [self.pickerView removeFromSuperview];
    }];
    [self.view addSubview:self.pickerView];
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(height);
    }];
}


- (void)rightPickerBtnAction {
    CGFloat height = 256;
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), height);
    self.pickerView = [LWPhotoPickerView photoPickerWithFrame:frame outSize:CGSizeMake(100, 160) pickedBlock:^(UIImage *image){
        if(!image){
            return;
        }

        UIImage *blurImg = [image blurImageWithRadius:(10 * 0.25)];
        //UIImage *kbBGImg = [blurImg imageToscaledSize:kbVC.inputView.frame.size];
        UIImage *pngImg = [UIImage imageWithData:UIImagePNGRepresentation(blurImg)];

        self.imageView.image = image;
        [self.pickerView removeFromSuperview];
    }];


    [self.view addSubview:self.pickerView];
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(height);
    }];
}


@end







@implementation UIImage(Blur)

//模糊化
-(UIImage *)blurImageWithRadius:(CGFloat)radius{
    return [self blurWithRect:CGRectMake(0, 0, self.size.width, self.size.height) radius:radius];
}

//将一张图片模糊化
- (UIImage *)blurWithRect:(CGRect)rect radius:(CGFloat)radius{
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];

    // Apply Affine-Clamp filter to stretch the image so that it does not
    // look shrunken when gaussian blur is applied
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setValue:inputImage forKey:@"inputImage"];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];

    // Apply gaussian blur filter with radius of 30
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:clampFilter.outputImage forKey: @"inputImage"];
    [gaussianBlurFilter setValue:@(radius) forKey:@"inputRadius"];

    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:gaussianBlurFilter.outputImage fromRect:[inputImage extent]];

    // Set up output context.
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();

    // Invert image coordinates
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -rect.size.height);

    // Draw base image.
    CGContextDrawImage(outputContext, rect, cgImage);

    // Apply white tint
    CGContextSaveGState(outputContext);
    CGContextSetFillColorWithColor(outputContext, [UIColor colorWithWhite:1 alpha:0.2].CGColor);
    CGContextFillRect(outputContext, rect);
    CGContextRestoreGState(outputContext);

    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return outputImage;
}

@end




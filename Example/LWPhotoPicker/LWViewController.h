//
//  LWViewController.h
//  LWPhotoPicker
//
//  Created by luowei on 05/07/2019.
//  Copyright (c) 2019 luowei. All rights reserved.
//

@import UIKit;

@interface LWViewController : UIViewController

@end



@interface UIImage (Blur)

//模糊化
-(UIImage *)blurImageWithRadius:(CGFloat)radius;

//将一张图片模糊化
- (UIImage *)blurWithRect:(CGRect)rect radius:(CGFloat)radius;

@end
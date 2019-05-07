//
//  LWViewController.m
//  libPhotoPicker
//
//  Created by luowei on 05/07/2019.
//  Copyright (c) 2019 luowei. All rights reserved.
//

#import <libPhotoPicker/LWAspectPhotoPickerView.h>
#import <Masonry/View+MASAdditions.h>
#import "LWViewController.h"

@interface LWViewController ()

@property(nonatomic, strong) LWAspectPhotoPickerView *pickerView;
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
    self.pickerView = [LWAspectPhotoPickerView pickerPhotoWithSize:CGSizeMake(100, 160) pickedBlock:^(UIImage *image){
        self.imageView.image = image;
        [self.pickerView removeFromSuperview];
    }];
    [self.view addSubview:self.pickerView];
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(256);
    }];
}


- (void)rightPickerBtnAction {

}


@end

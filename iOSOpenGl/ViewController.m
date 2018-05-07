//
//  ViewController.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/4/24.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "ViewController.h"
#import "OpenglView.h"
#import <GPUImage.h>
#import "macro.h"
#import "FishEyeFilter.h"
#import "InvertFilter.h"
#import "CustomBrightnessFilter.h"

@interface ViewController ()
@property (nonatomic,strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic,strong) GPUImageView *imageView;

@property (nonatomic,strong) GPUImageLookupFilter *filter;
@property (nonatomic,strong) GPUImagePicture *picture;
//@property (nonatomic,strong) UIImageView *imageView;
@end

@implementation ViewController
- (void)setupFilter
{
    self.imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.imageView];
    
    self.filter = [[GPUImageLookupFilter alloc] init];
    [self.filter setIntensity:0.65f];
    [self.filter addTarget:self.imageView];
    
    self.picture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"source.jpg"]];
    [self.picture addTarget:self.filter];
    [self.picture processImage];
    
    GPUImagePicture *loockup = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"lookup_amatorka.png"]];
    [loockup addTarget:self.filter];
    [loockup processImage];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupFilter];
}



@end

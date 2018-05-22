//
//  ColorController.m
//  iOSOpenGl
//
//  Created by 万 on 2018/5/20.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "ColorController.h"
#import <GPUImage.h>
#import "YJHalfGrayFilter.h"
#import "CustomAlphaBlendFilter.h"
#import "CustomFrameBlendThreeFilter.h"
#import "YJOldPhoteFilter.h"
#import "CustomSketchFilter.h"
#import "YJSnowFilter.h"
#import "HalfSketchFilter.h"
#import "FWAmaroFilter.h"

@interface ColorController ()
@property (nonatomic, strong) GPUImageView *imageView;
@property (nonatomic, strong) GPUImageStillCamera *camera;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong)  GPUImageLuminanceThresholdFilter *lumiFilter;
@property (nonatomic, strong) UIView *blendView;
@property (nonatomic, strong) UIImageView *coverImgView;

@property (nonatomic, strong) GPUImageUIElement *elemnet;
@property (nonatomic, strong) GPUImageUIElement *desEle;
@property (nonatomic, strong) GPUImageFilter *filter;
@end



@implementation ColorController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.imageView];
    
    // Do any additional setup after loading the view.
    self.camera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.camera.horizontallyMirrorRearFacingCamera = YES;
    //    self.camera.delegate = self;
    self.camera.horizontallyMirrorFrontFacingCamera = YES;//设置是否为镜像
    self.camera.horizontallyMirrorRearFacingCamera = NO;
    
    GPUImageMissEtikateFilter *filter = [[GPUImageMissEtikateFilter alloc]init];
    [self.camera addTarget:filter];
    [filter addTarget:self.imageView];
    
    [self.camera startCameraCapture];
    
}

@end

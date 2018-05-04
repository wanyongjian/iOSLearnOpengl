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
@property (nonatomic,strong) GPUImageView *filteredVideoView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
//    GPUImageFilter *customFilter = [[GPUImageGrayscaleFilter alloc]init];
//    GPUImageFilter *customFilter = [[FishEyeFilter alloc]init];
//    GPUImageBrightnessFilter *customFilter = [[GPUImageBrightnessFilter alloc]init];
    CustomBrightnessFilter *customFilter = [[CustomBrightnessFilter alloc] init];
    
    self.filteredVideoView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    
    [self.view addSubview:self.filteredVideoView];
    // Add the view somewhere so it's visible
    
    [self.videoCamera addTarget:customFilter];
    [customFilter addTarget:self.filteredVideoView];
    
    [self.videoCamera startCameraCapture];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        customFilter.brightness = 0.3;
    });
    
}
@end

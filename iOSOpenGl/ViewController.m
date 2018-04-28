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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GPUImageView *imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    imageView.fillMode = kGPUImageFillModePreserveAspectRatio;
    imageView.backgroundColor = RGB(0x253746, 1);
//    GPUImagePicture *picture = [[GPUImagePicture alloc]initWithImage:[UIImage imageNamed:@"wood.jpg"]];
    GPUImageStillCamera *camera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    camera.outputImageOrientation = UIInterfaceOrientationPortrait;
//    GPUImageGrayscaleFilter *filter = [[GPUImageGrayscaleFilter alloc]init];
//    [camera addTarget:filter];
    [camera addTarget:imageView];
//    [filter useNextFrameForImageCapture];
//    [picture processImage];
    [camera startCameraCapture];
    
    [self.view addSubview:imageView];
}
@end

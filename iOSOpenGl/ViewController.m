//
//  ViewController.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/4/24.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage.h>

@interface ViewController ()

@property (nonatomic, strong) GPUImageView *imageView;
@property (nonatomic, strong) GPUImageStillCamera *camera;
@property (nonatomic, strong) GPUImageUIElement *element;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.camera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.imageView];
    
    GPUImageMultiplyBlendFilter *blendFilter = [[GPUImageMultiplyBlendFilter alloc]init];
    
    UIView *backView = [[UIView alloc]initWithFrame:self.view.frame];
    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"awesomeface.jpg"]];
    imgView.frame = CGRectMake(100, 100, 100, 100);
    [backView addSubview:imgView];
    self.element = [[GPUImageUIElement alloc]initWithView:backView];
    [self.element addTarget:blendFilter];
    //加这个直通滤镜是为了在这个滤镜的回调里面更新element
    GPUImageFilter *filter = [[GPUImageFilter alloc]init];
    [self.camera addTarget:filter];
    [filter addTarget:blendFilter];
    
    [blendFilter addTarget:self.imageView];
    
    __weak typeof(self) weakSelf = self;
    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        [weakSelf.element update];
    }];
    [self.camera startCameraCapture];
    
}

@end

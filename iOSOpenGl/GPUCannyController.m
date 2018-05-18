//
//  GPUCannyController.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/18.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "GPUCannyController.h"

@interface GPUCannyController ()

@end

@implementation GPUCannyController

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
    
    GPUImageCannyEdgeDetectionFilter *filter = [[GPUImageCannyEdgeDetectionFilter alloc]init];
    [self.camera addTarget:filter];
    [filter addTarget:self.imageView];
    
    [self.camera startCameraCapture];
}



@end

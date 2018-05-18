//
//  GPUCannyController.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/18.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "GPUCannyController.h"
#import "CustomAlphaBlendFilter.h"
@interface GPUCannyController ()

@end

@implementation GPUCannyController
//检测出光源思路
//边缘检测后，将小光源轮廓膨胀成高亮点（膨胀多大？之后是否需要腐蚀？），然后再和源图像点乘，得到去除无效区域的图像
//二值化？然后OpenCV找轮廓，去除大面积点？
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
    
    CustomAlphaBlendFilter *blendFilter = [[CustomAlphaBlendFilter alloc]init];
    [self.camera addTarget:blendFilter];
    GPUImageCannyEdgeDetectionFilter *filter = [[GPUImageCannyEdgeDetectionFilter alloc]init];
    [self.camera addTarget:filter];

    GPUImageDilationFilter *dilationFilter1 = [[GPUImageDilationFilter alloc]initWithRadius:9];
    [filter addTarget:dilationFilter1];
    GPUImageErosionFilter *erosion = [[GPUImageErosionFilter alloc]initWithRadius:9];
    [dilationFilter1 addTarget:erosion];
    [erosion addTarget:blendFilter];
    
    [blendFilter addTarget:self.imageView];
    [self.camera startCameraCapture];
}



@end

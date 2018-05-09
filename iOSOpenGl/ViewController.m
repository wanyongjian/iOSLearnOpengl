//
//  ViewController.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/4/24.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage.h>
#import "CustomBeautyfaceFilter.h"

@interface ViewController ()

@property (nonatomic, strong) GPUImageView *imageView;
@property (nonatomic, strong) GPUImageStillCamera *camera;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) CustomBeautyfaceFilter *beautyFilter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.camera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.camera.horizontallyMirrorRearFacingCamera = YES;
    self.imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.imageView];

    //双边滤波
    GPUImageBilateralFilter *bilateralFilter = [[GPUImageBilateralFilter alloc]init];
    bilateralFilter.distanceNormalizationFactor = 4;
    [self.camera addTarget:bilateralFilter];
    //边缘检测
    GPUImageCannyEdgeDetectionFilter *cannyFilter = [[GPUImageCannyEdgeDetectionFilter alloc]init];
    [self.camera addTarget:cannyFilter];
    //美颜
    self.beautyFilter = [[CustomBeautyfaceFilter alloc]init];
    [bilateralFilter addTarget:self.beautyFilter];
    [cannyFilter addTarget:self.beautyFilter];
    [self.camera addTarget:self.beautyFilter];
    
    [self.beautyFilter addTarget:self.imageView];

    [self.camera startCameraCapture];

    self.slider = [[UISlider alloc]initWithFrame:CGRectMake(20, 30, 300, 50)];
    self.slider.minimumValue = 0.0;
    self.slider.maximumValue = 1.0;
    [self.view addSubview:self.slider];
    [self.slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)sliderAction:(UISlider *)slider{
    self.beautyFilter.blendIntensity = slider.value;
}
//
//- (void)paster{
//    //这个混合滤镜是混合算法是= 原图像*(1-目标的alpha)+目标图像*alpha
//    //主要作用是将目标图像的非透明区域替换到源图像上，所已第一个输入源必须是源图像，self.camera 要先添加，之后才是self.element
//    GPUImageSourceOverBlendFilter *blendFilter = [[GPUImageSourceOverBlendFilter alloc]init];
//
//    //加这个直通滤镜是为了在这个滤镜的回调里面更新element
//    GPUImageFilter *filter = [[GPUImageFilter alloc]init];
//    [self.camera addTarget:filter];
//    [filter addTarget:blendFilter];
//
//    UIView *backView = [[UIView alloc]initWithFrame:self.view.frame];
//    backView.backgroundColor = [UIColor clearColor];
//    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"awesomeface.jpg"]];
//    imgView.frame = CGRectMake(100, 100, 100, 100);
//    [backView addSubview:imgView];
//    self.element = [[GPUImageUIElement alloc]initWithView:backView];
//    [self.element addTarget:blendFilter];
//
//
//    [blendFilter addTarget:self.imageView];
//
//    __weak typeof(self) weakSelf = self;
//    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
//        [weakSelf.element update];
//    }];
//}
@end

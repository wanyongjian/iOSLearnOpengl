//
//  OpenCVController.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/14.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "OpenCVController.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/videoio/cap_ios.h>

@interface OpenCVController () <CvVideoCameraDelegate>

@property(nonatomic,strong) CvVideoCamera *videoCamera;
@property(nonatomic,strong) UIImageView *imageView;
@end

@implementation OpenCVController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.imageView];
    
    self.videoCamera = [[CvVideoCamera alloc]initWithParentView:self.imageView];
    //指定摄像机的摄像头方向（后置和前置）
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    //指定图像大小
    self.videoCamera.defaultAVCaptureSessionPreset =AVCaptureSessionPresetHigh;
    //设置相机方向
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    //    设置defaultFPS设置为摄像机的FPS，如果处理少于预期的FPS，帧被自动丢弃。
    self.videoCamera.defaultFPS =30;
    //    属性grayscale=YES使用不同的颜色空间，即 “YUV (YpCbCr 4:2:0)”，而grayscale=NO将输出32位BGRA。
    self.videoCamera.grayscaleMode =NO;
    self.videoCamera.delegate=self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.videoCamera start];
    });
}

-(void)processImage:(cv::Mat &)image{
    cv::Mat grayImage,result;
    cv::cvtColor(image, grayImage, CV_RGB2GRAY);
    //图像二值化，
    cv::threshold(grayImage, result, 254, 255, CV_THRESH_BINARY);
    //中值滤波去椒盐噪声
//    cv::medianBlur(result,result,3);
    image = result;
}
@end

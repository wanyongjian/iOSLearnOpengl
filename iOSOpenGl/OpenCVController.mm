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
    //色相
    int hmin = 0;
    int hmax = 360;
    float hmax_Max = 360.0;
    //亮度
    int lmin = 0;
    int lmax = 255;
    float lmax_Max = 255.0;
    //饱和度
    int smin = 0;
    int smax = 255;
    float smax_Max = 255.0;
    cv::cvtColor(image, result, CV_RGB2HLS);
    cv::inRange(result,cv::Scalar(hmin/hmax_Max, lmin / lmax_Max, smin / smax_Max), cv::Scalar(hmax/hmax_Max, lmax / lmax_Max, smax /smax_Max), result);
//    cv::cvtColor(image, grayImage, CV_RGB2GRAY);

    
    
    
//    //图像二值化，
//    cv::threshold(grayImage, result, 250, 255, CV_THRESH_BINARY);
//    //画矩形轮廓
//    std::vector<std::vector<cv::Point>> g_vContours; //数组
//    cv::findContours(result, g_vContours, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
//    cv::Mat Drawing = cv::Mat::zeros(result.size(), CV_8UC3);
//
//    NSLog(@"-=--=-= %lu",g_vContours.size());
//    for(int i= 0;i <g_vContours.size(); i++)
//    {
//        cv::Scalar colorWhite = cvScalar(255.0, 255.0, 255.0);
//        cv::Scalar colorYellow = cvScalar(255.0, 255.0, 0);
//        cv::drawContours(result, g_vContours, i, colorWhite); //画轮廓
//        double area = cv::contourArea(cv::Mat(g_vContours[i]));//计算轮廓面积
//
//        cv::Rect rect = cv::boundingRect(cv::Mat(g_vContours[i]));//轮廓外包矩形
//        cv::rectangle(result, rect, colorYellow); //画出矩形
////        NSLog(@"面积-- ： %f",area);
//        cv::Point cpt;
//        cpt.x = rect.x + cvRound(rect.width/2.0);
//        cpt.y = rect.y + cvRound(rect.height/2.0);
////        NSLog(@"中心-- ：x=%d,y=%d",cpt.x,cpt.y);
//    }

    image = result;
}
@end

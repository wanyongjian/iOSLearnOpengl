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

@property (nonatomic,strong) UIButton *selectButton;
@property (nonatomic,assign) BOOL useOtherCode;
@end

@implementation OpenCVController

- (void)buttonAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected == YES) {
        self.useOtherCode = YES;
        NSLog(@"使用....");
    }else{
        self.useOtherCode = NO;
        NSLog(@"不使用....");
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.imageView];
    self.selectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.selectButton.backgroundColor = [UIColor redColor];
    self.selectButton.frame = CGRectMake(0, 0, 100, 100);
    [self.view addSubview:self.selectButton];
    [self.selectButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
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
//    cv::Mat tmpH3(image.size(),CV_8U,cv::Scalar(0));

//    cv::cvtColor(image, grayImage, CV_BGR2HSV);
//    cv::inRange(grayImage,cv::Scalar(0,0,255), cv::Scalar(360,255,255), result);
//
    //灰度图
    cv::cvtColor(image, grayImage, CV_BGR2GRAY);
    //图像二值化，
    cv::threshold(grayImage, result, 253, 255, CV_THRESH_BINARY);
    //膨胀
    if (self.useOtherCode) {
        cv::Mat element = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5,5));
        cv::dilate(result, result, element);
        cv::dilate(result, result, element);
        cv::dilate(result, result, element);
        cv::dilate(result, result, element);
    }

    //膨胀

    //去椒盐噪声
//    cv::medianBlur(result, result, 3);
//    cv::dilate(result, result, 3);
//    cv::erode(result, result, 3);
    
//    //去除非常大的轮廓
//    std::vector<std::vector<cv::Point>> g_vContoursBig; //数组
//    cv::findContours(result, g_vContoursBig, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
//
//    for(int i= 0;i <g_vContoursBig.size(); i++)
//    {
//        double area = cv::contourArea(cv::Mat(g_vContoursBig[i]));//计算轮廓面积
//        cv::Rect rect = cv::boundingRect(cv::Mat(g_vContoursBig[i]));//轮廓外包矩形
//        cv::Point cpt;
//        cpt.x = rect.x + cvRound(rect.width/2.0);
//        cpt.y = rect.y + cvRound(rect.height/2.0);
//        if ((cpt.x *cpt.y) > 200) {
//            cv::floodFill(result, cpt, CvScalar(0,0,0));
//        }
//    }
    
    //画矩形轮廓
    std::vector<std::vector<cv::Point>> g_vContours; //数组
    cv::findContours(result, g_vContours, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
    cv::Mat Drawing = cv::Mat::zeros(result.size(), CV_8UC3);

    NSLog(@"-=--=-= %lu",g_vContours.size());
    for(int i= 0;i <g_vContours.size(); i++)
    {
        cv::Scalar colorWhite = cvScalar(255.0, 0, 255.0);
        cv::Scalar colorYellow = cvScalar(0, 0, 0);
        cv::drawContours(result, g_vContours, i, colorWhite); //画轮廓
        double area = cv::contourArea(cv::Mat(g_vContours[i]));//计算轮廓面积

        cv::Rect rect = cv::boundingRect(cv::Mat(g_vContours[i]));//轮廓外包矩形
        cv::rectangle(result, rect, colorYellow); //画出矩形
//        NSLog(@"面积-- ： %f",area);
        cv::Point cpt;
        cpt.x = rect.x + cvRound(rect.width/2.0);
        cpt.y = rect.y + cvRound(rect.height/2.0);
//        NSLog(@"中心-- ：x=%d,y=%d",cpt.x,cpt.y);
    }

    image = result;
}
@end

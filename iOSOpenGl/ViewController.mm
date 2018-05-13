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

#import <opencv2/opencv.hpp>

#import <opencv2/imgcodecs/ios.h>

#import <opencv2/imgproc/types_c.h>

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

//取出图片中亮度大于某个阈值的光源的面积和中心点
- (NSMutableArray *)getImageLightAreaAndCenter:(UIImage *)image withThresHold:(NSInteger)thresHold{
    NSMutableArray *lightInfoArray = [@[] mutableCopy];
    [lightInfoArray removeAllObjects];
    cv::Mat cvImage;
    UIImageToMat(image, cvImage);
    
    std::vector<std::vector<cv::Point>> g_vContours; //数组
    if(!cvImage.empty()){
        cv::Mat gray,result,blurGray;
        // 将图像转换为灰度显示
        result = cvImage.clone();
        cv::cvtColor(cvImage,gray,CV_RGB2GRAY);
        //图像二值化，
        cv::threshold(gray, result, thresHold, 255, CV_THRESH_BINARY_INV);
        //轮廓检测
        cv::findContours(result, g_vContours, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
        cv::Mat Drawing = cv::Mat::zeros(result.size(), CV_8UC3);
        for(int i= 0;i <g_vContours.size(); i++)
        {
            double area = cv::contourArea(cv::Mat(g_vContours[i]));//计算轮廓面积
            cv::Rect rect = cv::boundingRect(cv::Mat(g_vContours[i]));//轮廓外包矩形
            //            NSLog(@"面积-- ： %f",area);
            cv::Point cpt;
            cpt.x = rect.x + cvRound(rect.width/2.0);
            cpt.y = rect.y + cvRound(rect.height/2.0);
            //            NSLog(@"中心-- ：x=%d,y=%d",cpt.x,cpt.y);
            
            [lightInfoArray addObject:@[@(area),[NSValue valueWithCGPoint:CGPointMake(cpt.x, cpt.y)]]];
        }
    }
    return lightInfoArray;
}

@end

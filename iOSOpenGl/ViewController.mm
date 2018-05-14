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

@interface ViewController () <GPUImageVideoCameraDelegate>

@property (nonatomic, strong) GPUImageView *imageView;
@property (nonatomic, strong) GPUImageStillCamera *camera;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) CustomBeautyfaceFilter *beautyFilter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.camera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.camera.horizontallyMirrorRearFacingCamera = YES;
    self.camera.delegate = self;
    self.camera.horizontallyMirrorFrontFacingCamera = YES;//设置是否为镜像
    self.camera.horizontallyMirrorRearFacingCamera = NO;

    self.imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.imageView];

    GPUImageGrayscaleFilter *filter = [[GPUImageGrayscaleFilter alloc]init];
    [self.camera addTarget:filter];
    [filter addTarget:self.imageView];

    [self.camera startCameraCapture];

    self.slider = [[UISlider alloc]initWithFrame:CGRectMake(20, 30, 300, 50)];
    self.slider.minimumValue = 0.0;
    self.slider.maximumValue = 1.0;
    [self.view addSubview:self.slider];
    [self.slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    UIImage *image = [self convertSampleBufferToUIImageSampleBuffer:sampleBuffer];
    NSMutableArray *array = [self getImageLightAreaAndCenter:image withThresHold:240];
    //        UIImage *desImage = MatToUIImage(image);
    NSLog(@"%ld",array.count);
//    dispatch_async(dispatch_get_global_queue(0, 0),^{
//        //进入另一个线程
//                NSMutableArray *array = [self getImageLightAreaAndCenter:image withThresHold:240];
//        //        UIImage *desImage = MatToUIImage(image);
//                NSLog(@"%ld",array.count);
//        dispatch_async(dispatch_get_main_queue(),^{
//            //返回主线程
//
//        });
//    });

}

//取出图片中亮度大于某个阈值的光源的面积和中心点
- (NSMutableArray *)getImageLightAreaAndCenter:(UIImage *)image withThresHold:(NSInteger)thresHold{
    NSMutableArray *lightInfoArray = [@[] mutableCopy];
    [lightInfoArray removeAllObjects];
    
    cv::Mat grayImage;
    UIImageToMat(image, grayImage);
    
    std::vector<std::vector<cv::Point>> g_vContours; //数组
    if(!grayImage.empty()){
        cv::Mat result,blurGray;
        // 将图像转换为灰度显示
        result = grayImage.clone();
        //图像二值化，
        cv::threshold(grayImage, result, thresHold, 255, CV_THRESH_BINARY_INV);
        
        UIImage *image2 = MatToUIImage(result);
        //轮廓检测
        cv::findContours(result, g_vContours, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
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


////取出图片中亮度大于某个阈值的光源的面积和中心点
//- (NSMutableArray *)getImageLightAreaAndCenter:(cv::Mat )cvImage withThresHold:(NSInteger)thresHold{
//    NSMutableArray *lightInfoArray = [@[] mutableCopy];
//    [lightInfoArray removeAllObjects];
////    cv::Mat cvImage = image;
////    UIImageToMat(image, cvImage);
//
//    std::vector<std::vector<cv::Point>> g_vContours; //数组
//    if(!cvImage.empty()){
//        cv::Mat gray,result,blurGray;
//        // 将图像转换为灰度显示
//        result = cvImage.clone();
//        cv::cvtColor(cvImage,gray,CV_RGB2GRAY);
//        UIImage *image11 = MatToUIImage(gray);
//        //图像二值化，
//        cv::threshold(gray, result, thresHold, 255, CV_THRESH_BINARY_INV);
//
//        UIImage *image2 = MatToUIImage(result);
//        //轮廓检测
//        cv::findContours(result, g_vContours, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
//        cv::Mat Drawing = cv::Mat::zeros(result.size(), CV_8UC3);
//        for(int i= 0;i <g_vContours.size(); i++)
//        {
//            double area = cv::contourArea(cv::Mat(g_vContours[i]));//计算轮廓面积
//            cv::Rect rect = cv::boundingRect(cv::Mat(g_vContours[i]));//轮廓外包矩形
//            //            NSLog(@"面积-- ： %f",area);
//            cv::Point cpt;
//            cpt.x = rect.x + cvRound(rect.width/2.0);
//            cpt.y = rect.y + cvRound(rect.height/2.0);
//            //            NSLog(@"中心-- ：x=%d,y=%d",cpt.x,cpt.y);
//
//            [lightInfoArray addObject:@[@(area),[NSValue valueWithCGPoint:CGPointMake(cpt.x, cpt.y)]]];
//        }
//
//    }
//    return lightInfoArray;
//}

- (UIImage *)convertSampleBufferToUIImageSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the plane pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    
    // Get the number of bytes per row for the plane pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent gray color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGImageAlphaNone);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
    
}

- (void)sliderAction:(UISlider *)slider{
    self.beautyFilter.blendIntensity = slider.value;
}

@end

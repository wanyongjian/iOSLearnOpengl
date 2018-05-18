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
#import "CustomUIElement.h"

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc/types_c.h>


@interface ViewController () <GPUImageVideoCameraDelegate>

@property (nonatomic, strong) GPUImageView *imageView;
@property (nonatomic, strong) GPUImageStillCamera *camera;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong)  GPUImageLuminanceThresholdFilter *lumiFilter;
@property (nonatomic, strong) UIView *blendView;
@property (nonatomic, strong) CustomUIElement *element;
@property (nonatomic, strong) UIImageView *coverImgView;
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
    
    self.blendView = [[UIView alloc]initWithFrame:self.view.frame];
    self.blendView.backgroundColor = [UIColor clearColor];
    
    self.imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.imageView];
    
//    self.coverImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
//    self.coverImgView.frame = CGRectMake(0, 0, 80, 80);
//    [self.view addSubview:self.coverImgView];
    //这个混合滤镜是混合算法是= 原图像*(1-目标的alpha)+目标图像*alpha
    //主要作用是将目标图像的非透明区域替换到源图像上，所已第一个输入源必须是源图像，self.camera 要先添加，之后才是self.element
    GPUImageSourceOverBlendFilter *blendFilter = [[GPUImageSourceOverBlendFilter alloc]init];
    
    //加这个直通滤镜是为了在这个滤镜的回调里面更新element
    GPUImageFilter *filter = [[GPUImageFilter alloc]init];
    [self.camera addTarget:filter];
    [filter addTarget:blendFilter];
    

    self.element = [[CustomUIElement alloc]initWithView:self.blendView];
    [self.element addTarget:blendFilter];    
    
    [blendFilter addTarget:self.imageView];
    
    __weak typeof(self) weakSelf = self;
    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
//        weakSelf.element = [[GPUImageUIElement alloc]initWithView:weakSelf.blendView];
        [weakSelf.element update];
    }];
    
//    //灰度
//    GPUImageGrayscaleFilter *filter = [[GPUImageGrayscaleFilter alloc]init];
//    [self.camera addTarget:filter];
//    //亮度二值化
//    self.lumiFilter = [[GPUImageLuminanceThresholdFilter alloc]init];
//    self.lumiFilter.threshold = 253.8015/255.0;
//    [filter addTarget:self.lumiFilter];
//    //膨胀多次
//    GPUImageDilationFilter *dilationFilter1 = [[GPUImageDilationFilter alloc]initWithRadius:3];
//    [self.lumiFilter addTarget:dilationFilter1];
//    GPUImageDilationFilter *dilationFilter2 = [[GPUImageDilationFilter alloc]initWithRadius:3];
//    [dilationFilter1 addTarget:dilationFilter2];
//    [dilationFilter2 addTarget:self.imageView];

    [self.camera startCameraCapture];

    self.slider = [[UISlider alloc]initWithFrame:CGRectMake(20, 30, 300, 50)];
    self.slider.minimumValue = 0.97;
    self.slider.maximumValue = 1.0;
    [self.view addSubview:self.slider];
    [self.slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    UIImage *grayImage = [self convertSampleBufferToUIImageSampleBuffer:sampleBuffer]; //灰度图像
//    image.imageOrientation
//    NSLog(@"图片宽高：%f,%f",image.size.width,image.size.height);
    GPUImagePicture *GPUPicture = [[GPUImagePicture alloc]initWithImage:grayImage];
    //灰度
//    GPUImageGrayscaleFilter *filter = [[GPUImageGrayscaleFilter alloc]init];
//    [picture addTarget:filter];
    //亮度二值化
    self.lumiFilter = [[GPUImageLuminanceThresholdFilter alloc]init];
    self.lumiFilter.threshold = 253.8015/255.0;
//    self.lumiFilter.threshold = 1.0;
    [GPUPicture addTarget:self.lumiFilter];
    //膨胀
    GPUImageDilationFilter *dilationFilter1 = [[GPUImageDilationFilter alloc]initWithRadius:3];
    [self.lumiFilter addTarget:dilationFilter1];
    GPUImageDilationFilter *dilationFilter2 = [[GPUImageDilationFilter alloc]initWithRadius:3];
    [dilationFilter1 addTarget:dilationFilter2];

    __weak typeof(self) weakSelf = self;
    [dilationFilter2 setFrameProcessingCompletionBlock:^(GPUImageOutput *filter, CMTime time) {
        CGImageRef buffer = [filter.framebufferForOutput newCGImageFromFramebufferContents];
        UIImage* filterImage = [UIImage imageWithCGImage:buffer];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableArray *array = [weakSelf getImageLightAreaAndCenter:filterImage withThresHold:220];
//            NSLog(@"-=-=-=: %lu",(unsigned long)array.count);
            //更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                UIView *view = [[UIView alloc]initWithFrame:self.view.frame];
                view.backgroundColor = [UIColor clearColor];
                for (NSInteger i=0; i<array.count; i++) {
                    UIImage *image = [UIImage imageNamed:@"awesomeface.jpg"];
                    UIImageView *imgView = [[UIImageView alloc]initWithImage:image];
                    imgView.frame = CGRectMake(0, 0, 30, 30);
                    [view addSubview:imgView];
                    CGPoint centerPersent = [[[array objectAtIndex:i] objectAtIndex:1] CGPointValue];
                    imgView.center = CGPointMake(centerPersent.x*self.view.frame.size.width, centerPersent.y*self.view.frame.size.height);
                    
                }
                weakSelf.blendView = view;
                [weakSelf.element updateView:weakSelf.blendView];
            });
        });

    }];
    
    [GPUPicture processImage];

}

//取出图片中亮度大于某个阈值的光源的面积和中心点
- (NSMutableArray *)getImageLightAreaAndCenter:(UIImage *)image withThresHold:(NSInteger)thresHold{
    NSMutableArray *lightInfoArray = [@[] mutableCopy];
    [lightInfoArray removeAllObjects];
    
    cv::Mat grayImage;
    UIImageToMat(image, grayImage);
    cv::cvtColor(grayImage, grayImage, CV_BGR2GRAY);
//
    std::vector<std::vector<cv::Point>> g_vContours; //数组
    if(!grayImage.empty()){
        cv::Mat result,blurGray;
        //轮廓检测
        cv::findContours(grayImage, g_vContours, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
        UIImage *testimg = MatToUIImage(grayImage);
        for(int i= 0;i <g_vContours.size(); i++){
            double area = cv::contourArea(cv::Mat(g_vContours[i]));//计算轮廓面积
            if (area > 800) {
                continue; //忽略面积大的区域
            }
            cv::Rect rect = cv::boundingRect(cv::Mat(g_vContours[i]));//轮廓外包矩形
            NSLog(@"矩形x,y-- ： %d,%d",rect.x,rect.y);
            cv::Point cpt;
            float persentX;
            float persentY;
            cpt.x = rect.x + cvRound(rect.width/2.0);
            cpt.y = rect.y + cvRound(rect.height/2.0);
            float row = (float)grayImage.rows;
            float col = (float)grayImage.cols;
            persentX = cpt.x/col;
            persentY = cpt.y/row;
//            NSLog(@"中心-- ：x=%d,y=%d",cpt.x,cpt.y);
            [lightInfoArray addObject:@[@(area),[NSValue valueWithCGPoint:CGPointMake(persentX, persentY)]]];
        }
    }
    return lightInfoArray;
}


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
//    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationRight];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
    
}

- (void)sliderAction:(UISlider *)slider{
    self.lumiFilter.threshold = slider.value;
    NSLog(@"-----亮度：%f",slider.value);
}

@end

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
//    [self.camera addTarget:blendFilter];
    GPUImageCannyEdgeDetectionFilter *filter = [[GPUImageCannyEdgeDetectionFilter alloc]init];
    [self.camera addTarget:filter];

    GPUImageDilationFilter *dilationFilter1 = [[GPUImageDilationFilter alloc]initWithRadius:9];
    [filter addTarget:dilationFilter1];
    GPUImageErosionFilter *erosion = [[GPUImageErosionFilter alloc]initWithRadius:3];
    [dilationFilter1 addTarget:erosion];
    [erosion addTarget:blendFilter];
    
    GPUImageLuminanceThresholdFilter *thresFilter = [[GPUImageLuminanceThresholdFilter alloc]init];
    thresFilter.threshold = 250/255.0;
    [blendFilter addTarget:thresFilter];
    
    [filter addTarget:self.imageView];
    [self.camera startCameraCapture];
    
    [thresFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *filter, CMTime time) {
        CGImageRef buffer = [filter.framebufferForOutput newCGImageFromFramebufferContents];
        UIImage* filterImage = [UIImage imageWithCGImage:buffer];
        NSLog(@"image orientation:%ld",(long)filterImage.imageOrientation);
    }];
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

@end

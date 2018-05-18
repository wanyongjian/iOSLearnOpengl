//
//  GPUCannyController.h
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/18.
//  Copyright © 2018年 wan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage.h>

@interface GPUCannyController : UIViewController
@property (nonatomic, strong) GPUImageView *imageView;
@property (nonatomic, strong) GPUImageStillCamera *camera;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong)  GPUImageLuminanceThresholdFilter *lumiFilter;
@property (nonatomic, strong) UIView *blendView;
@property (nonatomic, strong) UIImageView *coverImgView;
@end

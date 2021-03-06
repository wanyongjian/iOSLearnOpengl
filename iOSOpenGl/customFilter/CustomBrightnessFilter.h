//
//  CustomBrightnessFilter.h
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/4.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "GPUImageFilter.h"

@interface CustomBrightnessFilter : GPUImageFilter{
    GLuint brightnessUniform;
}

@property (nonatomic,assign) CGFloat brightness;
@end

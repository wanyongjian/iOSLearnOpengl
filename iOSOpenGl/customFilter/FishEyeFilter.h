//
//  FishEyeFilter.h
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/3.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "GPUImageFilter.h"

@interface FishEyeFilter : GPUImageFilter

@property (nonatomic, assign) GLfloat radius;

- (instancetype)init;
@end

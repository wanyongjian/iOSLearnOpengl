//
//  CustomBeautyfaceFilter.h
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/9.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "GPUImageThreeInputFilter.h"

@interface CustomBeautyfaceFilter : GPUImageThreeInputFilter{
    GLuint blendUniform;
}
@property(nonatomic,assign) CGFloat blendIntensity;
@end

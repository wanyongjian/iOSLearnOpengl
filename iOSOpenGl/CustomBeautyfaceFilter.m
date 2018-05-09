//
//  CustomBeautyfaceFilter.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/9.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "CustomBeautyfaceFilter.h"

NSString *const BeautyfaceFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 varying highp vec2 textureCoordinate3;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 
 uniform highp float blendIntensity;
 void main()
 {
     highp vec4 colorBilateral = texture2D(inputImageTexture, textureCoordinate);
     highp vec4 colorCanny = texture2D(inputImageTexture2, textureCoordinate2);
     highp vec4 colorSource = texture2D(inputImageTexture3, textureCoordinate3);
     
     highp float r = colorSource.r;
     highp float g = colorSource.g;
     highp float b = colorSource.b;
     highp vec4 smooth;
     //不是边缘并且是皮肤才进行滤波
     if(colorCanny.r <0.5 && r > 0.3725 && g > 0.1568 && b > 0.0784 && r > b && r>g && (max(max(r, g), b) - min(min(r, g), b)) > 0.0588 && abs(r-g) > 0.0588){
//         smooth = colorBilateral; //取双边滤波值
         smooth = mix(colorSource,colorBilateral,blendIntensity);
//         smooth = colorSource;
     }else{
         smooth = colorSource;
     }
     gl_FragColor = smooth;
 }
 );


@implementation CustomBeautyfaceFilter
- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:BeautyfaceFragmentShaderString]))
    {
        
        return nil;
    }
    blendUniform = [filterProgram uniformIndex:@"blendIntensity"];
    self.blendIntensity = 0.5;
    return self;
}

- (void)setBlendIntensity:(CGFloat)blendIntensity{
    [self setFloat:blendIntensity forUniform:blendUniform program:filterProgram];
}

@end

//
//  CustomBrightnessFilter.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/4.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "CustomBrightnessFilter.h"

NSString *const BrightnessFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform float brightness;
 
 void main()
 {
     vec4 color = texture2D(inputImageTexture, textureCoordinate);
     gl_FragColor = vec4((color.rgb+vec3(brightness)),color.w);
 }
 );

@implementation CustomBrightnessFilter

- (instancetype)init
{
    if (self = [super initWithFragmentShaderFromString:BrightnessFilterFragmentShaderString]) {
    }
    brightnessUniform = [filterProgram uniformIndex:@"brightness"];
    self.brightness = 0.0;
    return self;
}

- (void)setBrightness:(CGFloat)brightness{
    _brightness = brightness;
    
    [self setFloat:brightness forUniform:brightnessUniform program:filterProgram];
}
@end

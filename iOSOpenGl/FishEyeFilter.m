//
//  FishEyeFilter.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/3.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "FishEyeFilter.h"

NSString *const kQMFishEyeFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform float radius;
 
 const float PI = 3.1415926535;
 
 void main()
 {
     float aperture = 175.0;
     float apertureHalf = radius * aperture * (PI / 180.0);
     float maxFactor = sin(apertureHalf);
     
     vec2 uv;
     vec2 xy = 2.0 * textureCoordinate - 1.0; //纹理坐标 0-1
     float d = length(xy);
     if (d < (2.0 - maxFactor)) {
         d = length(xy * maxFactor);
         float z = sqrt(1.0 - d * d);
         float r = atan(d, z) / PI;
         float phi = atan(xy.y, xy.x);
         
         uv.x = r * cos(phi) + radius;
         uv.y = r * sin(phi) + radius;
         
     }else {
         uv = textureCoordinate;
     }
     
     vec4 color = texture2D(inputImageTexture, uv);
     gl_FragColor = color;
 }
 );

@interface FishEyeFilter(){
    GLint radiusUniform;
}
@end

@implementation FishEyeFilter

- (instancetype)init
{
    if (self = [super initWithFragmentShaderFromString:kQMFishEyeFilterFragmentShaderString]) {
        
        radiusUniform = [filterProgram uniformIndex:@"radius"];
        self.radius = 0.5;
        
        [self setBackgroundColorRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    }
    return self;
}

- (void)setRadius:(GLfloat)radius
{
    _radius = radius;
    [self setFloat:_radius forUniform:radiusUniform program:filterProgram];
}
@end

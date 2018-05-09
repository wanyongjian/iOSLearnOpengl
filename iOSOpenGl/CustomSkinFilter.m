//
//  CustomSkinFilter.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/9.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "CustomSkinFilter.h"
NSString *const SkinFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     highp vec4 fragColor = texture2D(inputImageTexture, textureCoordinate);
     lowp float r = fragColor.r;
     lowp float g = fragColor.g;
     lowp float b = fragColor.b;
     highp vec4 skin;
     if ( r > 0.3725 && g > 0.1568 && b > 0.0784 && r > b && r>g && (max(max(r, g), b) - min(min(r, g), b)) > 0.0588 && abs(r-g) > 0.0588) {
         skin = fragColor;
     }else {
         skin = vec4(0.0);
     }
     gl_FragColor = skin;
 }
 );



@implementation CustomSkinFilter

- (instancetype)init
{
    if (self = [super initWithFragmentShaderFromString:SkinFilterFragmentShaderString]) {
    }
    return self;
}

@end

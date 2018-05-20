//
//  CustomHSVFilter.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/9.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "CustomHSVFilter.h"
NSString *const HSVFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 
 void main()
 {
     vec4 color = texture2D(inputImageTexture, textureCoordinate);
     highp float v = max(color.r,color.g);
     v = max(v,color.b);
     highp vec4 des;
     if(v>0.3){
         des = vec4(1.0,1.0,0.0,1.0);
     }else{
         des = color;
     }
     gl_FragColor = des;
 }
 );


@implementation CustomHSVFilter

- (instancetype)init
{
    if (self = [super initWithFragmentShaderFromString:HSVFilterFragmentShaderString]) {
    }
    return self;
}
@end

//
//  InvertFilter.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/4.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "InvertFilter.h"
NSString *const InvertFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;

 void main()
 {
     vec4 color = texture2D(inputImageTexture, textureCoordinate);
     gl_FragColor = vec4((1.0-color.rgb),color.w);
 }
 );


@implementation InvertFilter

- (instancetype)init
{
    if (self = [super initWithFragmentShaderFromString:InvertFilterFragmentShaderString]) {
    }
    return self;
}
@end

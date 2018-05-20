//
//  CustomAlphaBlendFilter.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/8.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "CustomAlphaBlendFilter.h"
NSString *const CustomAlphaBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     lowp float r1 = textureColor.r;
     lowp float g1 = textureColor.g;
     lowp float b1 = textureColor.b;
     
     lowp float r2 = textureColor2.r;
     lowp float g2 = textureColor2.g;
     lowp float b2 = textureColor2.b;
     lowp vec4 desColor = vec4(r1*r2,g1*g2,b1*b2,textureColor.a);
     //只输出亮度大于某个值的点
     highp float v = max(desColor.r,desColor.g);
//     v = max(v,desColor.b);
//     if(v>245.5/255.0){
//         desColor = desColor;
//     }else{
//         desColor = vec4(0.0,0.0,0.0,1.0);
//     }
     gl_FragColor = desColor;

 }
 );

@implementation CustomAlphaBlendFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:CustomAlphaBlendFragmentShaderString]))
    {
        
        return nil;
    }
    return self;
}

@end

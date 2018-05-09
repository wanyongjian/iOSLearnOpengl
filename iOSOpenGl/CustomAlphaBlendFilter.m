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
     lowp vec4 desColor = vec4(0.0);
//     if(textureColor2.a == 0.0){
//         desColor = textureColor;
//     }
//     if(textureColor.a == 0.0){
//         desColor = textureColor2;
//     }
     
     gl_FragColor = mix(textureColor, textureColor2, textureColor2.a);;
//     gl_FragColor = vec4(mix(textureColor.rgb, textureColor2.rgb, textureColor2.a * mixturePercent), textureColor.a);
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

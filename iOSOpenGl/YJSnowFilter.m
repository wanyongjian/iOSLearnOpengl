//
//  YJSnowFilter.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/22.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "YJSnowFilter.h"

NSString *const YJSnowFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;

 uniform sampler2D inputImageTexture;
// uniform lowp float iGlobalTime;
 const  lowp vec2 iResolution = vec2(512., 512.);
 const  lowp float iGlobalTime = 0.35;
 
lowp float rnd(lowp float x)
{
    return fract(sin(dot(vec2(x + 47.49, 38.2467 / (x + 2.3)),vec2(12.9898, 78.233))) * (43758.5453));
}
 
lowp float drawCircle(lowp vec2 uv, lowp vec2 center, lowp float radius)
{
    return 1.0 - smoothstep(0.0, radius, length(uv - center));
}

 void main()
 {
     lowp vec2 uv = textureCoordinate.xy / iResolution.x;
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     gl_FragColor = textureColor;

     
     lowp float j;
     // 生成若干个圆，当前uv依次与这些圆心计算距离，未落在圆域内则为黑色，落在圆域内则为白色
     for (int i = 0; i < 10; i++)
     {
         j = float(i);
         // 控制了不同雪花的下落速度 和 雪花的大小
         lowp float speed = 0.3+ rnd(cos(j))* (0.7+ 0.5* cos(j/ (float(400)* 0.25)));
         
         // Test
         //vec2 center = vec2(cos(iGlobalTime + sin(j)),
         //                     cos(iGlobalTime + cos(j)));
         lowp vec2 center = vec2(
                            // x坐标 左右环绕分布的范围
                            (-0.25 + uv.y) * 0.25 + rnd(j)+ 0.1 * cos(iGlobalTime + sin(j)),
                            // y坐标  随着时间下降
                            mod(rnd(j)- speed* (iGlobalTime * 1.5* (0.1 + 0.25)),0.95) );
         gl_FragColor += vec4(0.9 * drawCircle(uv, center, 0.001 + speed * 0.012)); // 输出是这些圆的颜色叠加
     }
 }
 );





@implementation YJSnowFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:YJSnowFragmentShaderString]))
    {
        return nil;
    }

    return self;
}
@end

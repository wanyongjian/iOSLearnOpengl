//
//  macro.h
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/4/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#ifndef macro_h
#define macro_h

#define WeakSelf __weak __typeof(self)weakSelf = self
#define StrongSelf __strong __typeof(weakSelf)strongSelf = weakSelf

#define ScreenWidth MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define ScreenHeight MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)

#define cameraWidth ScreenWidth
#define cameraHeight ((cameraWidth/480) *640)

#define Image_Paster(name) [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Image.bundle/images/%@",name]]]

//#define RGB(r,g,b) [UIColor colorWithRed:r green:g blue:b alpha:1]
#define RGB(c,a) [UIColor colorWithRed:((c&0xFF0000)>>16)/255.f green:((c&0xFF00)>>8)/255.f blue:(c&0xFF)/255.f alpha:a]
#define ZPosition @"zPosition"
#define KWidthPro(a) ((a)*ScreenWidth/712)

#endif /* macro_h */

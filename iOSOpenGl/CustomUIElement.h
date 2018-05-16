//
//  CustomUIElement.h
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/16.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "GPUImageOutput.h"

@interface CustomUIElement : GPUImageOutput
// Initialization and teardown
- (id)initWithView:(UIView *)inputView;
- (id)initWithLayer:(CALayer *)inputLayer;

// Layer management
- (CGSize)layerSizeInPixels;
- (void)update;
- (void)updateUsingCurrentTime;
- (void)updateWithTimestamp:(CMTime)frameTime;

//add by wan 2018.5.16
- (void)updateView:(UIView *)view;
@end

//
//  OpenglView.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/4/24.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "OpenglView.h"
#import <OpenGLES/ES3/gl.h>
#import "GLESUtils.h"

typedef struct {
    GLfloat x,y,z;
    GLfloat r,g,b;
} Vertex;

@interface OpenglView(){
    EAGLContext *_context;
    CAEAGLLayer *_eaglLayer;
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    GLuint _program;
    GLuint _vertCount;
    Vertex *_vertext;
    GLuint _vao;
}
@end

@implementation OpenglView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setLayer];
        [self setContext];
        [self destoryRenderAndFrameBuffer];
        [self render];
    }
    return self;
}

- (void)setProgram{
    NSString *vertex = [[NSBundle mainBundle]pathForResource:@"VertexShader.glsl" ofType:nil];
    NSString *fragment = [[NSBundle mainBundle]pathForResource:@"FragmentShader.glsl" ofType:nil];
    
    _program = createGLProgramFromFile(vertex.UTF8String, fragment.UTF8String);
    glUseProgram(_program);
}

+(Class)layerClass{
    // 只有 [CAEAGLLayer class] 类型的 layer 才支持在其上描绘 OpenGL 内容。
    return [CAEAGLLayer class];
}

- (void)setLayer{
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setContext{
    _context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!_context) {
        NSLog(@"fail initial opengles 2.0 context ");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"fail to set context");
        exit(1);
    }
}

- (void)setFrameAndRenderBuffer{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)destoryRenderAndFrameBuffer{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}
- (void)setVertexData{
    CGPoint p1 = CGPointMake(-0.8, 0);
    CGPoint p2 = CGPointMake(0.8, 0.2);
    CGPoint control = CGPointMake(0, -0.9);
    CGFloat deltaT = 0.01;
    
    _vertCount = 1.0/deltaT;
    _vertext = (Vertex *)malloc(sizeof(Vertex) * _vertCount);
    
    // t的范围[0,1]
    for (int i = 0; i < _vertCount; i++) {
        float t = i * deltaT;
        
        // 二次方计算公式Vertex
        float cx = (1-t)*(1-t)*p1.x + 2*t*(1-t)*control.x + t*t*p2.x;
        float cy = (1-t)*(1-t)*p1.y + 2*t*(1-t)*control.y + t*t*p2.y;
        _vertext[i] = (Vertex){cx, cy, 0.0, 1.0, 0.0, 0.0};
        
        printf("%f, %f\n",cx, cy);
    }
    
}
- (void)setVao{
    glGenVertexArrays(1, &_vao);
    glBindVertexArray(_vao);
    
    GLuint vbo = createVBO(GL_ARRAY_BUFFER, GL_STATIC_DRAW, sizeof(Vertex)*(_vertCount+1), _vertext);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), NULL);
    glEnableVertexAttribArray(0);
    
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), NULL+sizeof(float)*3);
    glEnableVertexAttribArray(1);
}
- (void)render{
    glClearColor(1.0, 1.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glLineWidth(2.0);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    [self setProgram];
    [self setFrameAndRenderBuffer];
    [self setVertexData];
    [self setVao];
    
    glBindVertexArrayOES(_vao);
    glDrawArrays(GL_LINE_STRIP, 0, _vertCount);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}
@end

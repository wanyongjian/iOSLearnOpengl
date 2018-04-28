//
//  OpenglView.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/4/24.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "OpenglView.h"
#import <OpenGLES/ES2/gl.h>
#import "GLESUtils.h"
#import "JpegUtil.h"

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
    GLuint _vbo;
    GLuint _texture1;
    GLuint _texture2;
}
@end

@implementation OpenglView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setLayer];
        [self setContext];
        [self destoryRenderAndFrameBuffer];
        [self setProgram];
        [self setFrameAndRenderBuffer];
        [self setVBO];
        
        [self setTexture1];
        [self setTexture2];
        
        [self render];
    }
    return self;
}

- (void)setVBO{
    _vertCount = 6;
    
    GLfloat vertices[] = {
        0.8f,  0.6f, 0.0f, 1.0f, 0.0f,   // 右上
        0.8f, -0.6f, 0.0f, 1.0f, 1.0f,   // 右下
        -0.8f, -0.6f, 0.0f, 0.0f, 1.0f,  // 左下
        -0.8f, -0.6f, 0.0f, 0.0f, 1.0f,  // 左下
        -0.8f,  0.6f, 0.0f, 0.0f, 0.0f,  // 左上
        0.8f,  0.6f, 0.0f, 1.0f, 0.0f,   // 右上
    };
    _vbo = createVBO(GL_ARRAY_BUFFER, GL_STATIC_DRAW, sizeof(vertices), vertices);
    
    glVertexAttribPointer(glGetAttribLocation(_program, "position"), 3, GL_FLOAT, GL_FALSE, 5*sizeof(float), NULL);
    glEnableVertexAttribArray(glGetAttribLocation(_program, "position"));
    
    glVertexAttribPointer(glGetAttribLocation(_program, "texcoord"), 2, GL_FLOAT, GL_FALSE, 5*sizeof(float), NULL+3*sizeof(float));
    glEnableVertexAttribArray(glGetAttribLocation(_program, "texcoord"));
}

- (void)setTexture1{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"wood" ofType:@"jpg"];
    
    unsigned char *data;
    int size;
    int width;
    int height;
    
    // 加载纹理
    if (read_jpeg_file(path.UTF8String, &data, &size, &width, &height) < 0) {
        printf("%s\n", "decode fail");
    }
    // 创建纹理
    _texture1 = createTexture2D(GL_RGB, width, height, data);
    
    if (data) {
        free(data);
        data = NULL;
    }
}
- (void)setTexture2{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"flower" ofType:@"jpg"];
    
    unsigned char *data;
    int size;
    int width;
    int height;
    
    // 加载纹理
    if (read_jpeg_file(path.UTF8String, &data, &size, &width, &height) < 0) {
        printf("%s\n", "decode fail");
    }
    // 创建纹理
    _texture2 = createTexture2D(GL_RGB, width, height, data);
    
    if (data) {
        free(data);
        data = NULL;
    }
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
    _context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
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

- (void)render{
    glClearColor(1.0, 1.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glLineWidth(2.0);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture1);
    glUniform1i(glGetUniformLocation(_program, "imageFlower"), 0);
    
//    glActiveTexture(GL_TEXTURE1);
//    glBindTexture(GL_TEXTURE_2D, _texture2);
//    glUniform1i(glGetUniformLocation(_program, "imageFlower"), 1);
    
    glDrawArrays(GL_TRIANGLES, 0, _vertCount);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}
@end

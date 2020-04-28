//
//  ES2Renderer.h
//  opengl_es_tweezers
//
//  Created by Richard Bowman on 22/07/2010.
//  Copyright University of Glasgow 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define SPOT_ELEMENTS 4 //the number of parameters per spot
#define MAX_N_SPOTS 10  //nb this must be smaller than the spots[] array size below
#define MESH_RESOLUTION 128 //DEFAULT resolution with which we render the hologram (can be changed)

//render modes
enum {
	RENDER_OUT_CMY,
	RENDER_OUT_CMY_AMPLITUDE,
    RENDER_OUT_AMPLITUDE,
	RENDER_OUT_BW,
	RENDER_OUT_BW_BINARY
};

// uniform index
enum {
	UNIFORM_SPOTS,
	UNIFORM_N,
	UNIFORM_SIZE,
	UNIFORM_OUTPUT_TYPE,
    UNIFORM_MESH_RESOLUTION,
    NUM_UNIFORMS
};


@interface ES2Renderer : NSObject
{
	int outputType;
@private
    EAGLContext *context;

    // The pixel dimensions of the CAEAGLLayer
    GLint backingWidth;
    GLint backingHeight;
    
    GLint meshResolution;
	
	//protect against rendering when we don't have a shader...
	BOOL readyToRender;

    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view
    GLuint defaultFramebuffer, colorRenderbuffer;

    GLuint program;
	GLfloat spots[SPOT_ELEMENTS*MAX_N_SPOTS];
	GLint nspots;
	
    GLint uniforms[NUM_UNIFORMS];

	//GLfloat triangleRow[(MESH_RESOLUTION*2+3)*2];
}

@property int outputType;
@property int meshResolution;

- (id)initWithOutputType:(int)oType;
- (float*)spotsArray;
- (void)setNumberOfSpots:(int)n;
- (void)render;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
- (void)reloadShaders;

@end


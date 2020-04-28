//
//  ES2Renderer.m
//  opengl_es_tweezers
//
//  Created by Richard Bowman on 22/07/2010.
//  Copyright University of Glasgow 2010. All rights reserved.
//

#import "ES2Renderer.h"

// attribute index
enum {
    ATTRIB_VERTEX,
    NUM_ATTRIBUTES
};

@interface ES2Renderer (PrivateMethods)
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation ES2Renderer

@synthesize outputType;
@synthesize meshResolution;

- (float*)spotsArray{
	return (float*) spots;
}

- (void)setNumberOfSpots:(int)n{
	nspots=n;
}

// Create an OpenGL ES 2.0 context
- (id)initWithOutputType:(int)oType;
{
	readyToRender = NO;
	outputType = oType;
	
    if ((self = [super init]))
    {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

        if (!context || ![EAGLContext setCurrentContext:context] || ![self loadShaders])
        {
            [self release];
            return nil;
        }
		
        // Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
        glGenFramebuffers(1, &defaultFramebuffer);
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
		
		for(int i=0; i<MAX_N_SPOTS*SPOT_ELEMENTS; i++) spots[i]=0;
		nspots=0;
		
        meshResolution=MESH_RESOLUTION;
        
		readyToRender=YES;
		
		srand((unsigned int) time(NULL));
    }

    return self;
}

-(id)init{
	return [self initWithOutputType:RENDER_OUT_CMY];
}

- (void)render
{
	if(!readyToRender) return; //don't render if we are doing stuff...
    if(backingWidth == 0 || backingHeight == 0) return; //no point rendering to a non-existent surface! (happens if this is called before the layer is set up)
	
    // This application only creates a single context which is already set current at this point.
    // This call is redundant, but needed if dealing with multiple contexts.
    [EAGLContext setCurrentContext:context];

    // This application only creates a single default framebuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple framebuffers.
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);

    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    // Use shader program
    glUseProgram(program);

	//fix aspect ratio
    
    GLint smallSide=backingWidth<backingHeight?backingWidth:backingHeight;
    GLfloat ylim=backingHeight/(GLfloat)smallSide;                                   //xlim and ylim are used to scale things so resolution is isotropic
    GLfloat xlim=backingWidth/(GLfloat)smallSide;                                    //one of them is always 1, the other is 1.33 (for 4:3 screens)
	float sw=meshResolution*xlim/4, sh=meshResolution*ylim/4; //these will be SLM width/height in mm
	
    // Update uniform value
	if(nspots>MAX_N_SPOTS) nspots=MAX_N_SPOTS; //bad things might happen...
	glUniform1i(uniforms[UNIFORM_N], nspots);
	glUniform4fv(uniforms[UNIFORM_SPOTS], MAX_N_SPOTS*SPOT_ELEMENTS/4, spots);
	glUniform2f(uniforms[UNIFORM_SIZE], sw,sh);
	glUniform1i(uniforms[UNIFORM_OUTPUT_TYPE], outputType);
	glUniform1i(uniforms[UNIFORM_MESH_RESOLUTION], meshResolution);
	//for(int i=0; i<SPOT_ELEMENTS*nspots; i++) spots[i]+=((GLfloat)rand()/(GLfloat)RAND_MAX -0.5)*1e-2;
	//spots[0]+=1e-3;
	
	//NSLog(@"spots[0-3] %e %e %e %e",spots[0],spots[1],spots[2],spots[3]);

	
    // Validate program before drawing. This is a good check, but only really necessary in a debug build.
    // DEBUG macro must be defined in your debug configurations if that's not already the case.
#if defined(DEBUG)
    if (![self validateProgram:program])
    {
        NSLog(@"Failed to validate program: %d", program);
        return;
    }
#endif

    GLint yres=ceil(ylim*meshResolution)+1;
    GLint xres=ceil(xlim*meshResolution)+1;
    //NSLog(@"mesh res %d",meshResolution);
    
    GLfloat stepSize=2.0f/((float)meshResolution);                          //this is the step size to use so that we have meshResolution points across the screen
    GLfloat * triangleRow=(GLfloat*)malloc(4*xres*sizeof(GLfloat)); //allocate memory for triangle row
	
    for(int i=0; i<yres; i++){
        GLfloat top=-ylim+i*stepSize;
        GLfloat bottom=top+stepSize;
        
        //divide by xlim and ylim in lieu of making the viewport dimensions correct...
        for(int j=0; j<xres; j++){
            triangleRow[4*j+0]=(-xlim+j*stepSize)/xlim;
            triangleRow[4*j+1]=(top)/ylim;
            triangleRow[4*j+2]=(-xlim+j*stepSize)/xlim;
            triangleRow[4*j+3]=(bottom)/ylim;
        }
//        NSLog(@"row from %f,%f to %f,%f, should be %f,%f",triangleRow[0],triangleRow[1],triangleRow[xres*2-2],triangleRow[xres*2-1],xlim,ylim);
        
		// Update attribute values
		glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, triangleRow);
		glEnableVertexAttribArray(ATTRIB_VERTEX);
		// Draw
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 2*xres);	

    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
    free(triangleRow);
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;

    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return FALSE;
    }

    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);

#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif

    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return FALSE;
    }

    return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;

    glLinkProgram(prog);

#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif

    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;

    return TRUE;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;

    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }

    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;

    return TRUE;
}

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;

    // Create shader program
    program = glCreateProgram();

    // Create and compile vertex shader
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return FALSE;
    }

    // Create and compile fragment shader
	switch(outputType){
		case(RENDER_OUT_CMY):
			fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader_cmy" ofType:@"fsh"];
			break;
		case(RENDER_OUT_CMY_AMPLITUDE):
			fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader_cmyamp" ofType:@"fsh"];
			break;
		case(RENDER_OUT_AMPLITUDE):
			fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader_amp" ofType:@"fsh"];
			break;
		case(RENDER_OUT_BW):
			fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader_bw" ofType:@"fsh"];
			break;
		case(RENDER_OUT_BW_BINARY):
			fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader_bw_binary" ofType:@"fsh"];
			break;
		default:
			fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader_rgb" ofType:@"fsh"];
			break;
	}
			
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return FALSE;
    }

    // Attach vertex shader to program
    glAttachShader(program, vertShader);

    // Attach fragment shader to program
    glAttachShader(program, fragShader);

    // Bind attribute locations
    // this needs to be done prior to linking
    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
//    glBindAttribLocation(program, ATTRIB_COLOR, "color");

    // Link program
    if (![self linkProgram:program])
    {
        NSLog(@"Failed to link program: %d", program);

        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program)
        {
            glDeleteProgram(program);
            program = 0;
        }
        
        return FALSE;
    }

    // Get uniform locations
    uniforms[UNIFORM_SPOTS] = glGetUniformLocation(program, "spots");
    uniforms[UNIFORM_N] = glGetUniformLocation(program, "n");
    uniforms[UNIFORM_SIZE] = glGetUniformLocation(program, "slmsize");
    uniforms[UNIFORM_MESH_RESOLUTION] = glGetUniformLocation(program, "meshResolution");

    // Release vertex and fragment shaders
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);

    return TRUE;
}

- (void)reloadShaders{
    if (program){
		readyToRender=NO;
        glDeleteProgram(program);
        program = 0;
		[self loadShaders];
		readyToRender=YES;
    }
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
    // Allocate color buffer backing based on the current layer size
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }

    NSLog(@"resized to %d,%d",backingWidth,backingHeight);
    return YES;
}

- (void)dealloc
{
    // Tear down GL
    if (defaultFramebuffer)
    {
        glDeleteFramebuffers(1, &defaultFramebuffer);
        defaultFramebuffer = 0;
    }

    if (colorRenderbuffer)
    {
        glDeleteRenderbuffers(1, &colorRenderbuffer);
        colorRenderbuffer = 0;
    }

    if (program)
    {
        glDeleteProgram(program);
        program = 0;
    }

    // Tear down context
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];

    [context release];
    context = nil;

    [super dealloc];
}

@end

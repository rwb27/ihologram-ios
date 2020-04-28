//
//  EAGLView.m
//  opengl_es_tweezers
//
//  Created by Richard Bowman on 22/07/2010.
//  Copyright University of Glasgow 2010. All rights reserved.
//

#import "EAGLView.h"

#import "ES2Renderer.h"
#import "SpotController.h"

@implementation EAGLView



@synthesize animating;
@synthesize renderer;
@synthesize spotController;
@dynamic animationFrameInterval;
- (int) meshResolution{return (renderer)?renderer.meshResolution:MESH_RESOLUTION;}
- (void)setMeshResolution:(int)meshResolution{if(renderer) renderer.meshResolution=meshResolution;}



// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;

        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];

        renderer = [[ES2Renderer alloc] init];

        if (!renderer)
        {
			NSLog(@"FATAL ERROR: the device needs to support OpenGL ES 2.0");
			[self release];
			return nil;
        }

        animating = FALSE;
        displayLinkSupported = FALSE;
        animationFrameInterval = 3;
        displayLink = nil;
        animationTimer = nil;

        // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
        // class is used as fallback when it isn't available.
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            displayLinkSupported = TRUE;
    }
	
	spotController = [[SpotController alloc] initWithView:self];
	
    return self;
}

- (void)drawView:(id)sender
{	[spotController updateRenderer:renderer];
    [renderer render];
}

- (void)displayLayer:(CALayer *)layer{
    [self drawView:self];
}

- (void)drawViewIfChanged:(id)sender{
	if([spotController hasChanged])[self drawView:sender];
}

- (void)layoutSubviews
{
    [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self drawView:nil];
}
- (void)setBounds:(CGRect)bounds{
    [super setBounds:bounds];
    [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self drawView:nil];
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;

        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        if (displayLinkSupported)
        {
            // CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
            // if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
            // not be called in system versions earlier than 3.1.

            displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawViewIfChanged:)];
            [displayLink setFrameInterval:animationFrameInterval];
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawViewIfChanged:) userInfo:nil repeats:TRUE];

        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        if (displayLinkSupported)
        {
            [displayLink invalidate];
            displayLink = nil;
        }
        else
        {
            [animationTimer invalidate];
            animationTimer = nil;
        }

        animating = FALSE;
    }
}

/*- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGSize size = self.bounds.size;
	float* spots = [renderer spotsArray];
	NSInteger touchCount = 0;
	for(UITouch *touch in touches){
		CGPoint pos = [touch locationInView:self];
		spots[SPOT_ELEMENTS*touchCount]=(pos.x/size.width-0.5);
		spots[SPOT_ELEMENTS*touchCount+1]=(-pos.y/size.height+0.5);
		touchCount++;
		if(touchCount==MAX_N_SPOTS) break; //don't let the pointer pixies eat you...
	}
	[renderer setNumberOfSpots:touchCount];
}*/



- (int) outputType{
	return [self.renderer outputType];
}
- (void)setOutputType:(int)outputType{
	//this should only be called when we are not animating
	[self stopAnimation];
//	[renderer release];
//	renderer = [[ES2Renderer alloc] initWithOutputType:outputType];
	renderer.outputType=outputType;
	[renderer reloadShaders];
	NSLog(@"changed output type to %d (EAGLView)",outputType);
    if(outputType==RENDER_OUT_BW_BINARY){
//        self.layer.contentsScale=0.1;
    }else{
//        self.layer.contentsScale=[[UIScreen mainScreen] scale];
    }
//    [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
//	[self setNeedsLayout];
	[renderer render];
}

- (void)dealloc
{
	[spotController release];
    [renderer release];

    [super dealloc];
}

@end

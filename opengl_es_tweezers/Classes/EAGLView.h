//
//  EAGLView.h
//  opengl_es_tweezers
//
//  Created by Richard Bowman on 22/07/2010.
//  Copyright University of Glasgow 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class ES2Renderer;
@class SpotController;


// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView
{    
@private
    ES2Renderer *renderer;
	SpotController* spotController;

    BOOL animating;
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;
    // Use of the CADisplayLink class is the preferred method for controlling your animation timing.
    // CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
    // The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
    // isn't available.
    id displayLink;
    NSTimer *animationTimer;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (readonly, nonatomic) ES2Renderer *renderer;
@property int outputType;
@property (readonly) SpotController * spotController;
@property int meshResolution;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView:(id)sender;
- (void)drawViewIfChanged:(id)sender;

@end

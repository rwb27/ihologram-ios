//
//  SpotController.m
//  opengl_es_tweezers
//
//  Created by Richard Bowman on 03/08/2010.
//  Copyright 2010 University of Glasgow. All rights reserved.
//

#import "SpotController.h"
#import "SpotView.h"
#import "ES2Renderer.h"


@implementation SpotController

@synthesize hasChanged;



- (id) initWithView:(UIView *)spotLocation{
	controlledView = [spotLocation retain];
	spotObjects = [NSMutableSet setWithCapacity:MAX_N_SPOTS];

	[spotObjects retain];
	
    for(int n=1; n<12; n++){
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGestureOnBackground:)];
        [tapGestureRecognizer setNumberOfTapsRequired:2];
        [tapGestureRecognizer setNumberOfTouchesRequired:n];
        [controlledView addGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
    }
	
//	UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestureOnBackground:)];
//	[controlledView addGestureRecognizer:longPressGestureRecognizer];
//	[longPressGestureRecognizer release];
//	
	hasChanged = YES;
	
	return self;
}

- (void) createDefaultSpots{
	//separate this from initWithView because we might need to react to a resize first (iPad vs iPhone)
	float width=controlledView.bounds.size.width, height=controlledView.bounds.size.height;
	float ox=controlledView.bounds.origin.x, oy=controlledView.bounds.origin.y;
	NSLog(@" rectangle %f %f %f %f",ox,oy,width,height);
	CGPoint spotPos;
	spotPos.x = ox+width*0.5+21;
	spotPos.y = oy+height*0.5+4;
	SpotView *spotView = [[SpotView alloc] initAtLocation:spotPos inView:controlledView withController:self];
	[spotObjects addObject:spotView];
	[spotView release];
	spotPos.x= ox+width*0.4+12;
	spotPos.y= oy+height*0.25+23;
	spotView=[[SpotView alloc] initAtLocation: spotPos inView:controlledView withController:self];
	[spotObjects addObject:spotView];
	[spotView release];
	spotPos.x= ox+width*0.7-6;
	spotPos.y= oy+height*0.75-13;
	spotView=[[SpotView alloc] initAtLocation: spotPos inView:controlledView withController:self];
	[spotObjects addObject:spotView];
	[spotView release];
	
	hasChanged=YES;
}

- (float) sizeAtZeroDepth{
	return controlledView.bounds.size.height*0.07+70;
}

- (void) postDeleteSpotObject:(SpotView *)spotView{
	//this should really be somewhere else...
	if(spotView!=nil){
		[spotObjects removeObject:spotView];
		[spotView setHidden:YES];
		[spotView removeFromSuperview];
		spotView=nil;
		hasChanged=YES;
	}
	
}

- (void) updateRenderer:(ES2Renderer *)renderer{
	CGSize size = controlledView.bounds.size;
	float* spotsArray=[renderer spotsArray];
	int n=0;
    float w=size.width>size.height?size.width:size.height; //find max.dimension
	for(SpotView *spotView in spotObjects){
		float* spot=&spotsArray[n*SPOT_ELEMENTS];
		spot[0]=(size.width/2-spotView.x)/w;
		spot[1]=(spotView.y-size.height/2)/w;
		spot[2]=(spotView.z/w);
		spot[3]=(float)spotView.l;
		n++;
		if(n>=MAX_N_SPOTS) break;
	}
	[renderer setNumberOfSpots:n];
	
	hasChanged=NO; //this flag tells us if we need to bother re-rendering...
}

- (void) rotateCoordinatesBy:(float)rotation duration:(NSTimeInterval)duration{
    CGSize viewSize=controlledView.bounds.size;
    
    if(rotation<0) rotation +=360;
        
//    [CATransaction begin];
//    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
    for(SpotView *spotView in spotObjects){
        CGSize newSize=viewSize;
        CGPoint newCenter=spotView.center;
        if(fmodf(rotation,180)==90){
            newCenter=CGPointMake(viewSize.height-newCenter.y,newCenter.x);
            newSize=CGSizeMake(viewSize.height,viewSize.width);
        }
        if(rotation >=180){
            newCenter=CGPointMake(newSize.width-newCenter.x,newSize.height-newCenter.y);
        }
        [spotView setXY:newCenter]; //do this rather than just setting center so that it keeps its internal x, y in sync.
    }
//    [CATransaction commit];
}

#pragma mark === Touchy Stuff ===
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	return YES;
}
- (void)handleDoubleTapGestureOnBackground:(UITapGestureRecognizer*)gestureRecognizer{
    for(int i=0; i<[gestureRecognizer numberOfTouches]; i++){
        SpotView* spotView=[[SpotView alloc] initAtLocation:[gestureRecognizer locationOfTouch:i inView:controlledView] inView:controlledView withController:self];
        [spotObjects addObject:spotView];
        [spotView release];
    }
	hasChanged=YES;
}

@end

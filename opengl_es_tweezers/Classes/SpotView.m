//
//  SpotView.m
//  opengl_es_tweezers
//
//  Created by Richard Bowman on 28/07/2010.
//  Copyright 2010 University of Glasgow. All rights reserved.
//

#import "SpotView.h"
#import <QuartzCore/QuartzCore.h>
#import "SpotController.h"

//#define SIZE_AT_ZERO_DEPTH 140 //we now use [controller sizeAtZeroDepth] instead.

@implementation SpotView

@synthesize x;
@synthesize y;
@synthesize z;
@synthesize l;

static UIImage* beadImage;
BOOL haveIncrementedLSinceGestureStart=NO;
SpotController* controller;

-(void) setZ:(float)newz{
	z=newz;
	CGRect bounds = self.bounds; //I don't understand fully why I can't just set self.bounds.size myself...
	bounds.size=CGSizeMake(z+[controller sizeAtZeroDepth], z+[controller sizeAtZeroDepth]);
	self.bounds=bounds;
	
	controller.hasChanged=YES;
}

-(void) setXY:(CGPoint)newxy{
	x=newxy.x;
	y=newxy.y;
	self.center=newxy;
	
	controller.hasChanged=YES;
}
-(void) translate:(CGPoint)translation{
	CGPoint newxy = self.center;
	newxy.x += translation.x;
	newxy.y += translation.y;
	[self setXY:newxy];
}

#pragma mark === Gesture Setup ===
-(void) addGestureRecognizers{
	UIPinchGestureRecognizer *pinchGestureRecogniser = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [pinchGestureRecogniser setDelegate:self];
    [self addGestureRecognizer:pinchGestureRecogniser];
    [pinchGestureRecogniser release];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [panGestureRecognizer setMaximumNumberOfTouches:2];
    [panGestureRecognizer setDelegate:self];
    [self addGestureRecognizer:panGestureRecognizer];
    [panGestureRecognizer release];
	
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
	[tapGestureRecognizer setNumberOfTapsRequired:2];
    [self addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
	
	UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationGesture:)];
    [self addGestureRecognizer:rotationGestureRecognizer];
    [rotationGestureRecognizer release];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	return YES;
}


#pragma mark === Gesture Actions ===
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}


- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer{
//    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
	
	
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [self setZ:((self.z+[controller sizeAtZeroDepth])*[gestureRecognizer scale]-[controller sizeAtZeroDepth])]; //
        [gestureRecognizer setScale:1];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer{
//    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
	
	
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [self translate:[gestureRecognizer translationInView:self.superview]]; //
        [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
    }
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)gestureRecognizer{
	//if (!([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged)) return;
	[controller postDeleteSpotObject:self];
	
}

- (void)handleRotationGesture:(UIRotationGestureRecognizer *)gestureRecognizer{
	if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) haveIncrementedLSinceGestureStart=NO; //only increment if (1) we moved at least 90 degrees and (2) only increment at the end of the gesture
	if([gestureRecognizer state] == UIGestureRecognizerStateChanged && !haveIncrementedLSinceGestureStart){
		if([gestureRecognizer rotation]>3.141/4.0){
			l++;
			haveIncrementedLSinceGestureStart=YES;
			controller.hasChanged=YES;
		}
		if((-1)*[gestureRecognizer rotation]>3.141/2.0){
			l--;
			haveIncrementedLSinceGestureStart=YES;
			controller.hasChanged=YES;
		}
	}
}



-(id) init{
	if(beadImage==nil){
		beadImage=[UIImage imageNamed:@"bead.png"];
	}else{
		[beadImage retain];
	}
	[super initWithImage:beadImage];
	[self setZ:0];
	
	self.multipleTouchEnabled=YES;
	self.userInteractionEnabled=YES;
	
	return self;
}

-(id) initAtLocation:(CGPoint)xy inView:(UIView *)superview withController:(SpotController *)spotController{
	[super init];
	[self init];
	controller=[spotController retain];
	[superview addSubview:self];
	[self setXY:xy];
	[self addGestureRecognizers];
	[self setZ:0.0];
	
	return self;
}

-(void) dealloc{
	//[self removeFromSuperview];
//	for(UIGestureRecognizer* gestureRecognizer in [self gestureRecognizers]){
//		[gestureRecognizer removeTarget:self action:NULL];
	//	}
	controller.hasChanged=YES;
	[controller release];
	[super dealloc];
}
		 
@end

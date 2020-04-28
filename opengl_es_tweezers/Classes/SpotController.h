//
//  SpotController.h
//  opengl_es_tweezers
//
//  Created by Richard Bowman on 03/08/2010.
//  Copyright 2010 University of Glasgow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ES2Renderer;
@class SpotView;

@interface SpotController : NSObject {
	@private
	UIView * controlledView;
	NSMutableSet *spotObjects;
	SpotView *spotViewToDelete;
	BOOL hasChanged;
}

@property (readonly) float sizeAtZeroDepth;
@property BOOL hasChanged;

- (id) initWithView:(UIView *)spotLocation;
- (void)postDeleteSpotObject:(SpotView*)spotView;
- (void) updateRenderer:(ES2Renderer *)renderer;
- (void) createDefaultSpots;
- (void) rotateCoordinatesBy:(float)rotation duration:(NSTimeInterval)duration;

@end

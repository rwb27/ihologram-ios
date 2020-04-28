//
//  SpotView.h
//  opengl_es_tweezers
//
//  Created by Richard Bowman on 28/07/2010.
//  Copyright 2010 University of Glasgow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SpotController;


@interface SpotView : UIImageView <UIGestureRecognizerDelegate> {
	float x;
	float y;
	float z;
	int l;
}

@property (readonly) float x;
@property (readonly) float y;
@property (readonly) float z;
@property int l;

-(id) init;
-(id) initAtLocation:(CGPoint)xy inView:(UIView *)superview withController:(SpotController*)controller;


-(void) setZ:(float)z;
-(void) setXY:(CGPoint)newxy;
-(void) translate:(CGPoint)translation;

@end

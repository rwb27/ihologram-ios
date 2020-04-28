//
//  MainViewController.h
//  opengl_es_tweezers
//
//  Created by Richard Bowman on 29/08/2010.
//  Copyright 2010 University of Glasgow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlipsideViewController.h"

@class EAGLView;

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate> {
	FlipsideViewController * flipsideViewController;
	IBOutlet EAGLView * glView;
    UIInterfaceOrientation lastOrientation; //used to rotate spots if the view is rotated while we're in the flipside view
}

- (IBAction)showInfo:(id)sender;
- (void)flipsideViewControllerAnimatedDismissalDidFinish:(id)sender;
- (void)rotateSpotsFromInterfaceOrientation:(UIInterfaceOrientation)fromOrientation toInterfaceOrientation:toOrientation duration:(NSTimeInterval)duration;
@property(retain) IBOutlet EAGLView * glView;

@end

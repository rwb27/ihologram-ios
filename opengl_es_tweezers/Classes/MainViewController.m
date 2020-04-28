    //
//  MainViewController.m
//  opengl_es_tweezers
//
//  Created by Richard Bowman on 29/08/2010.
//  Copyright 2010 University of Glasgow. All rights reserved.
//

#import "MainViewController.h"
#import "EAGLView.h"
#import "SpotController.h"


@implementation MainViewController
@synthesize glView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//load the flipside view controller in the background so the transition is snazzier
	flipsideViewController = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	flipsideViewController.delegate = self;
	flipsideViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[flipsideViewController retain];
	
    glView.outputType=(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"outputType"];
    glView.meshResolution=(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"meshResolution"];
    
	//put some spots on it
	[[glView spotController] createDefaultSpots]; //create three spots not quite in a line (suitable for portrait orientation)
    if(UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        [[glView spotController] rotateCoordinatesBy:90 duration:0]; //rotate if in landscape
        NSLog(@"started in landscape: rotating default spots");
    }
    NSLog(@"view did load");
}



#pragma mark -
#pragma mark === Flipside Stuff ===

- (IBAction)showInfo:(id)sender {    
	[glView stopAnimation];
    lastOrientation = [UIApplication sharedApplication].statusBarOrientation;
	[self presentViewController:flipsideViewController animated:YES completion:nil];
}

- (int)outputType{
	return [glView outputType];
}

- (void)setOutputType:(int)outputType{
	[glView setOutputType:outputType];
    [[NSUserDefaults standardUserDefaults] setInteger:outputType forKey:@"outputType"];
	[glView drawView:self];
}
- (int)meshResolution{
	return [glView meshResolution];
}

- (void)setMeshResolution:(int)meshResolution{
    NSLog(@"setting mesh resolution to:%d",meshResolution);
	[glView setMeshResolution:meshResolution];
    [[NSUserDefaults standardUserDefaults] setInteger:meshResolution forKey:@"meshResolution"];
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    [glView drawView:self];
    if(lastOrientation!=[UIApplication sharedApplication].statusBarOrientation){ //rotate the spots if the device was rotated in flipside view.
        float r = fmodf([self angleOfOrientation:[UIApplication sharedApplication].statusBarOrientation] - [self angleOfOrientation:lastOrientation],360.0f);
        [[glView spotController] rotateCoordinatesBy:r duration:0];
    }
	[self dismissViewControllerAnimated:YES completion:nil];
	[NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(flipsideViewControllerAnimatedDismissalDidFinish:) userInfo:nil repeats:NO];
}
- (void)flipsideViewControllerAnimatedDismissalDidFinish:(id)sender{
	[glView startAnimation];
}
	
#pragma mark -
#pragma mark === Standard ViewController Stuff ===

- (void)viewWillDisappear:(BOOL)animated{
	[glView stopAnimation];
	[super viewWillDisappear:animated];
}
	

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (float)angleOfOrientation:(UIInterfaceOrientation)orientation{
    switch(orientation){
        case UIInterfaceOrientationPortrait:
            return 0;
        case UIInterfaceOrientationLandscapeLeft:
            return 90;
        case UIInterfaceOrientationPortraitUpsideDown:
            return 180;
        case UIInterfaceOrientationLandscapeRight:
            return 270;
    }
    return -1;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self rotateSpotsFromInterfaceOrientation:self.interfaceOrientation toInterfaceOrientation:toInterfaceOrientation duration:duration];
}
- (void)rotateSpotsFromInterfaceOrientation:(UIInterfaceOrientation)fromOrientation toInterfaceOrientation:toOrientation duration:(NSTimeInterval)duration{
    float r = fmodf([self angleOfOrientation:toOrientation] - [self angleOfOrientation:fromOrientation],360.0f);
    [[glView spotController] rotateCoordinatesBy:r duration:duration];
    [glView.spotController updateRenderer:glView.renderer]; //ensure the spots are kept in sync with the renderer
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[flipsideViewController release];
    [super dealloc];
}


@end

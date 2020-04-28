//
//  FlipsideViewController.m
//  itweezers
//
//  Created by Richard Bowman on 24/07/2010.
//  Copyright University of Glasgow 2010. All rights reserved.
//

#import "FlipsideViewController.h"


@implementation FlipsideViewController

@synthesize delegate;
@synthesize outputTypeSelector;
@synthesize meshResolutionSlider;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
    [self enableTrilinearFilteringOnView:self.view];
	[outputTypeSelector setSelectedSegmentIndex:[self.delegate outputType]];
    for(int i=0; i<outputTypeSelector.numberOfSegments; i++){ //make the images in the segmented control show correctly!
        [outputTypeSelector setImage:[[outputTypeSelector imageForSegmentAtIndex:i] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:i];
    }
    [meshResolutionSlider setValue:[self.delegate meshResolution]];
}

- (void)enableTrilinearFilteringOnView:(UIView *)view{ //recursively enable trilinear filtering on all images - useful for images that get scaled up/down for different devices
    NSArray* subviews = view.subviews;
    if(subviews.count>0){
        for(UIView * subview in subviews){
            if([subview isKindOfClass:[UIImageView class]]) [subview.layer setMinificationFilter:kCAFilterTrilinear];
            if(subview.subviews.count > 0) [self enableTrilinearFilteringOnView:subview];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
}

#pragma mark -
#pragma mark === IB Actions for controls ===
- (IBAction)outputTypeDidChange:(UISegmentedControl *)sender{
	[self.delegate setOutputType:(int)sender.selectedSegmentIndex];
}
- (IBAction)meshResolutionDidChange:(id)sender{
    [self.delegate setMeshResolution:(int)[meshResolutionSlider value]];
    NSLog(@"mesh resolution updated to %f",[meshResolutionSlider value]);
}
- (IBAction)done:(id)sender {
	[self.delegate flipsideViewControllerDidFinish:self];	
}
- (IBAction)openWebsite:(id)sender {
	if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://www.physics.gla.ac.uk/Optics/projects/tweezers/ipad.php"]]) 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.physics.gla.ac.uk/Optics/projects/tweezers/ipad.php"]];
}
- (IBAction)openCreativeCamerasWebsite:(id)sender {
	if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://cameras.eps.hw.ac.uk/"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://cameras.eps.hw.ac.uk/"]];
}

#pragma mark -
#pragma mark === Standard ViewController Stuff ===

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return YES;
}



- (void)dealloc {
    [super dealloc];
}


@end

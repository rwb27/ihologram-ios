//
//  FlipsideViewController.h
//  itweezers
//
//  Created by Richard Bowman on 24/07/2010.
//  Copyright University of Glasgow 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : UIViewController {
	id <FlipsideViewControllerDelegate> delegate;
	IBOutlet UISegmentedControl * outputTypeSelector;
    IBOutlet UISlider * meshResolutionSlider;
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UISegmentedControl * outputTypeSelector;
@property (nonatomic, retain) IBOutlet UISlider * meshResolutionSlider;
- (IBAction)outputTypeDidChange:(id)sender;
- (IBAction)meshResolutionDidChange:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)openWebsite:(id)sender;
- (IBAction)openCreativeCamerasWebsite:(id)sender;
@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@property int outputType;
@property int meshResolution;
@end


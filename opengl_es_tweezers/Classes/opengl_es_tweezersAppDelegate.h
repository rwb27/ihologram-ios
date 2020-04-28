//
//  opengl_es_tweezersAppDelegate.h
//  opengl_es_tweezers
//
//  Created by Richard Bowman on 22/07/2010.
//  Copyright University of Glasgow 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;
@class MainViewController;

@interface opengl_es_tweezersAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
    MainViewController * mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;

@end


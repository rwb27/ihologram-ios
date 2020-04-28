//
//  opengl_es_tweezersAppDelegate.m
//  opengl_es_tweezers
//
//  Created by Richard Bowman on 22/07/2010.
//  Copyright University of Glasgow 2010. All rights reserved.
//

#import "opengl_es_tweezersAppDelegate.h"
#import "EAGLView.h"
#import "MainViewController.h"

@implementation opengl_es_tweezersAppDelegate

@synthesize window;
@synthesize mainViewController;

- (id) init{
    self=[super init];
    
    NSDictionary * applicationDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInt:0],@"outputType",
                                          [NSNumber numberWithInt:128],@"meshResolution",
                                          NULL];
    [[NSUserDefaults standardUserDefaults] registerDefaults:applicationDefaults];
    
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Add the main view controller's view to the window and display.
//    [window addSubview:mainViewController.view];
    window.rootViewController = mainViewController;
    [window makeKeyAndVisible];
    
    glView=[mainViewController glView];
    
    [glView startAnimation];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [glView stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [glView startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [glView stopAnimation];
}

- (void)dealloc
{
    [window release];
    [glView release];

    [super dealloc];
}

@end

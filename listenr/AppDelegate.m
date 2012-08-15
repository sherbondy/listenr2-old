//
//  AppDelegate.m
//  listenr
//
//  Created by Ethan Sherbondy on 8/11/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeVC.h"
#import "Theme.h"

@implementation AppDelegate

+ (id)sharedDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    HomeVC *homeVC = [HomeVC new];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:homeVC];
    self.window.rootViewController = navController;
    
    [Theme apply];
            
    return YES;
}

@end

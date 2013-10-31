//
//  Theme.m
//  listenr
//
//  Created by Ethan Sherbondy on 8/11/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import "Theme.h"
#import "AudioPlayerVC.h"

@implementation Theme

+ (void)apply {
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor purpleColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}

@end

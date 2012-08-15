//
//  AppDelegate.m
//  listenr
//
//  Created by Ethan Sherbondy on 8/11/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "AppDelegate.h"
#import "AudioPlayerVC.h"
#import "HomeVC.h"
#import "Theme.h"

@implementation AppDelegate

+ (id)sharedDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

// Suggested in: http://stackoverflow.com/questions/4771105/how-do-i-get-my-avplayer-to-play-while-app-is-in-background
- (void)fixAudioRoute
{
    // Set AudioSession
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    /* Pick any one of them */
    // 1. Overriding the output audio route
    //UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    //AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    // 2. Changing the default output audio route
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [self fixAudioRoute];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    HomeVC *homeVC = [HomeVC new];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:homeVC];
    self.window.rootViewController = navController;
    
    [Theme apply];
            
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch(event.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause:
            [[AudioPlayerVC sharedVC] togglePlayback:nil];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            [[AudioPlayerVC sharedVC] triggerPrevious:nil];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            [[AudioPlayerVC sharedVC] triggerNext:nil];
            break;
        case UIEventSubtypeRemoteControlPlay:
            [[AudioPlayerVC sharedVC] playSong];
            break;
        case UIEventSubtypeRemoteControlPause:
            [[AudioPlayerVC sharedVC] pause];
            break;
        case UIEventSubtypeRemoteControlStop:
            [[AudioPlayerVC sharedVC] pause];
            break;
        default:
            break;
    }
}

@end

//
//  AudioPlayerVC.m
//  listenr
//
//  Created by Ethan Sherbondy on 8/14/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

#import "AudioPlayerVC.h"
#import "Song.h"
#import "Theme.h"

@interface AudioPlayerVC ()
- (void)play;
- (void)pause;
@end

@implementation AudioPlayerVC

+ (id)sharedVC
{
    static AudioPlayerVC *playerVC;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerVC = [[AudioPlayerVC alloc] init];
    });
    return playerVC;
}

- (void)playNewTrack
{
    Song *newSong = [[self datasource] currentSong];
    if (_currentSong != newSong){
        _currentSong = newSong;
        [_player replaceCurrentItemWithPlayerItem:[self.currentSong playerItem]];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[AVPlayer self]]){
        
        if ([[change objectForKey:@"new"] intValue] == AVPlayerStatusReadyToPlay){
            NSLog(@"Time to play!");
            [self play];
        }
    }
}

- (void)play {
    [self.player play];
    [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
}

- (void)pause {
    [self.player pause];
    [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
}

- (IBAction)togglePlayback:(id)sender {
    if ([self.player rate] == 1.0){
        [self pause];
    } else {
        [self play];
    }
}

- (id)init
{
    self = [self initWithNibName:NSStringFromClass([AudioPlayerVC class]) bundle:[NSBundle mainBundle]];
    if (self){
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _player = [[AVPlayer alloc] init];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _timeFormatter = [[NSDateFormatter alloc] init];
        [_timeFormatter setDateFormat:@"mm':'ss"];
        [_timeFormatter setLocale:usLocale];
    }
    return self;
}

- (NSString *)prettyTimeFromSeconds:(float)seconds
{
    return [_timeFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:seconds]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];

    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float progressSeconds = CMTimeGetSeconds(time);
        float durationSeconds = CMTimeGetSeconds(self.player.currentItem.duration);
        [self.progressSlider setValue:(progressSeconds/durationSeconds)];
        
        AudioPlayerVC *playerVC = [AudioPlayerVC sharedVC];
        [self.progressLabel setText:[playerVC prettyTimeFromSeconds:progressSeconds]];
        [self.durationLabel setText:[playerVC prettyTimeFromSeconds:durationSeconds]];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIView animateWithDuration:0.3 animations:^{
        [[[self navigationController] navigationBar] setTintColor:[UIColor blackColor]];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:0.3 animations:^{
        UINavigationBar *navBar = [self navigationController].navigationBar;
        [navBar setTintColor:[[UINavigationBar appearance] tintColor]];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

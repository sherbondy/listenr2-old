//
//  AudioPlayerVC.m
//  listenr
//
//  Created by Ethan Sherbondy on 8/14/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MediaPlayer/MediaPlayer.h>

#import "AudioPlayerVC.h"
#import "Song.h"
#import "Theme.h"
#import "Blog.h"

@interface AudioPlayerVC ()
- (NSString *)prettyStringForDate:(NSDate *)date;
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
        [self.albumArt setImageWithURL:[NSURL URLWithString:newSong.album_art] placeholderImage:[UIImage imageNamed:@"album_full"]];
        
        [self.captionWebView loadHTMLString:_currentSong.caption baseURL:[NSURL URLWithString:_currentSong.post_url]];
        [self.authorLabel    setText:_currentSong.blog.name];
        [self.postDateLabel  setText:[self prettyStringForDate:_currentSong.timestamp]];
        
        [self.songTitleLabel setText:_currentSong.track_name];
        [self.artistLabel    setText:_currentSong.artist];
        [self.albumLabel     setText:_currentSong.album];
        
        [_player replaceCurrentItemWithPlayerItem:[self.currentSong playerItem]];
        if (self.player.status == AVPlayerStatusReadyToPlay){
            [self play];
        }
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
    if (self.player.status != AVPlayerStatusReadyToPlay){
        [self.playButton setTitle:@"Loading" forState:UIControlStateNormal];
    } else {
        [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

- (void)playSong {
    [self play];
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
        
        _postDateFormatter = [[NSDateFormatter alloc] init];
        [_postDateFormatter setDateStyle:NSDateFormatterLongStyle];
        [_postDateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    return self;
}



- (void)togglePlaybackStatusBar
{
    self.playbackStatusBar.hidden = !self.playbackStatusBar.isHidden;
}

- (IBAction)toggleInfo:(id)sender {
    UIView *fromContainer;
    UIView *toContainer;
    UIViewAnimationOptions flipDirection;
    if (self.infoViewContainer.isHidden){
        fromContainer = self.albumViewContainer;
        toContainer   = self.infoViewContainer;
        flipDirection = UIViewAnimationOptionTransitionFlipFromLeft;
        
    } else {
        fromContainer = self.infoViewContainer;
        toContainer   = self.albumViewContainer;
        flipDirection = UIViewAnimationOptionTransitionFlipFromRight;
    }
    
    [UIView transitionFromView:fromContainer toView:toContainer duration:0.3
                       options:(flipDirection|UIViewAnimationOptionShowHideTransitionViews)
                    completion:^(BOOL finished) {
    }];
}

- (float)playerSeconds {
    return CMTimeGetSeconds(self.player.currentTime);
}

- (float)durationSeconds {
    return CMTimeGetSeconds(self.player.currentItem.duration);
}

- (void)noSongsLeft {
    [self pause];
    _currentSong = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)beganScrubbing:(id)sender {
    [self pause];
}

- (IBAction)finishedScrubbing:(id)sender {
    float percentage = [(UISlider *)sender value];
    [self.player seekToTime:CMTimeMakeWithSeconds(self.durationSeconds*percentage, 1)];
    [self play];
}


- (IBAction)triggerPrevious:(id)sender {
    // Jump to beginning of track
    if ([self playerSeconds] > 1){
        [self.player seekToTime:CMTimeMakeWithSeconds(0, 1)];
    } else {
        if ([self.datasource hasPrevious]){
            [self.datasource playPrevious];
        } else {
            [self noSongsLeft];
        }
    }
}

- (IBAction)triggerNext:(id)sender {
    if ([self.datasource hasNext]){
        [self.datasource playNext];
    } else {
        [self noSongsLeft];
    }
}


#pragma mark Formatting

- (NSString *)prettyStringForDate:(NSDate *)date
{
    return [_postDateFormatter stringFromDate:_currentSong.timestamp];
}

- (NSString *)prettyTimeFromSeconds:(float)seconds
{
    return [_timeFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:seconds]];
}


#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];

    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float progressSeconds = CMTimeGetSeconds(time);
        float durationSeconds = self.durationSeconds;
        [self.progressSlider setValue:(progressSeconds/durationSeconds)];
        
        AudioPlayerVC *playerVC = [AudioPlayerVC sharedVC];
        [self.progressLabel setText:[playerVC prettyTimeFromSeconds:progressSeconds]];
        [self.durationLabel setText:[playerVC prettyTimeFromSeconds:durationSeconds]];
    }];
    
    self.navigationItem.rightBarButtonItem = self.rightInfoButton;
    [self.navigationItem setTitleView:self.navTitleView];
    
    [self.captionWebView setDelegate:self];
    
    UITapGestureRecognizer *albumTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePlaybackStatusBar)];
    [self.albumArt addGestureRecognizer:albumTapRecognizer];
    
    // Now we can safely begin receiving remote control events.
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
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

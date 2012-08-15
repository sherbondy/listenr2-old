//
//  AudioPlayerVC.h
//  listenr
//
//  Created by Ethan Sherbondy on 8/14/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;
@class Song;

@protocol AudioPlayerDatasource <NSObject>

- (BOOL)hasPrevious;
- (void)playPrevious;
- (Song *)previousSong;

- (Song *)currentSong;

- (BOOL)hasNext;
- (void)playNext;
- (Song *)nextSong;

@end

@interface AudioPlayerVC : UIViewController <UIWebViewDelegate> {
    NSDateFormatter *_timeFormatter;
    NSDateFormatter *_postDateFormatter;
};

@property (strong, nonatomic, readonly) Song     *currentSong;
@property (nonatomic, readonly)         float     durationSeconds;

@property (weak, nonatomic)   IBOutlet UILabel  *progressLabel;
@property (weak, nonatomic)   IBOutlet UISlider *progressSlider;
@property (strong, nonatomic) IBOutlet UILabel  *durationLabel;

@property (weak, nonatomic)   IBOutlet UIImageView *albumArt;
@property (weak, nonatomic)   IBOutlet UIView      *playbackStatusBar;

@property (weak, nonatomic)   IBOutlet UIView *infoViewContainer;
@property (weak, nonatomic)   IBOutlet UIView *albumViewContainer;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightInfoButton;


@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;
@property (weak, nonatomic) IBOutlet UIWebView *captionWebView;

@property (weak, nonatomic)   IBOutlet UIButton  *previousButton;
@property (weak, nonatomic)   IBOutlet UIButton  *playButton;
@property (weak, nonatomic)   IBOutlet UIButton  *nextButton;

@property (strong, nonatomic) IBOutlet UIView *navTitleView;
@property (weak, nonatomic)   IBOutlet UILabel *songTitleLabel;
@property (weak, nonatomic)   IBOutlet UILabel *albumLabel;
@property (weak, nonatomic)   IBOutlet UILabel *artistLabel;

@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, weak)             id<AudioPlayerDatasource> datasource;

+ (id)sharedVC;
- (void)playNewTrack;

@end
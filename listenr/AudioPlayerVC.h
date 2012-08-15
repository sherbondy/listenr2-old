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

- (Song *)currentSong;
- (Song *)nextSong;
- (Song *)previousSong;

@end

@interface AudioPlayerVC : UIViewController {
    NSDateFormatter *_timeFormatter;
};

@property (strong, nonatomic, readonly) Song     *currentSong;

@property (weak, nonatomic)   IBOutlet  UILabel  *progressLabel;
@property (weak, nonatomic)   IBOutlet  UISlider *progressSlider;
@property (strong, nonatomic) IBOutlet  UILabel  *durationLabel;

@property (weak, nonatomic)   IBOutlet UIButton  *previousButton;
@property (weak, nonatomic)   IBOutlet UIButton  *playButton;
@property (weak, nonatomic)   IBOutlet UIButton  *nextButton;

@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, weak)             id<AudioPlayerDatasource> datasource;

+ (id)sharedVC;
- (void)playNewTrack;

@end
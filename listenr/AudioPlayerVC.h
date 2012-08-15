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

@property (weak, nonatomic)   IBOutlet  UILabel *progressLabel;
@property (strong, nonatomic) IBOutlet  UILabel *durationLabel;
@property (weak, nonatomic)   IBOutlet  UISlider *progressSlider;
@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, weak)             id<AudioPlayerDatasource> datasource;

+ (id)sharedVC;
- (void)play;

@end
//
//  Song.m
//  listenr
//
//  Created by Ethan Sherbondy on 8/13/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "Song.h"
#import "Blog.h"
#import "NSManagedObject+Additions.h"

@implementation Song

@dynamic album;
@dynamic album_art;
@dynamic artist;
@dynamic audio_url;
@dynamic caption;
@dynamic timestamp;
@dynamic post_id;
@dynamic liked;
@dynamic post_url;
@dynamic reblog_key;
@dynamic track_name;
@dynamic blog;

// consider adding tag support

// post_id == id in tumblr land

+ (Song *)songForAttrs:(NSDictionary *)songAttrs
{
    Song *song = [Song objectWithAttrs:songAttrs];
    
    NSString *songID = [songAttrs objectForKey:@"id"];
    if (songID){
        [song setValue:songID forKey:@"post_id"];
    }
    return song;
}

- (AVPlayerItem *)playerItem
{
    return [AVPlayerItem playerItemWithURL:[self trueAudioURL]];
}

- (NSURL *)trueAudioURL
{
    return [NSURL URLWithString:[self.audio_url stringByAppendingString:@"?plead=please-dont-download-this-or-our-lawyers-wont-let-us-host-audio"]];
}

@end

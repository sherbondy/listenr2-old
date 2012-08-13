//
//  Song.h
//  listenr
//
//  Created by Ethan Sherbondy on 8/13/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Blog;

@interface Song : NSManagedObject

@property (nonatomic, strong) NSString * album;
@property (nonatomic, strong) NSString * album_art;
@property (nonatomic, strong) NSString * artist;
@property (nonatomic, strong) NSString * audio_url;
@property (nonatomic, strong) NSString * caption;
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSNumber * post_id;
@property (nonatomic, strong) NSNumber * liked;
@property (nonatomic, strong) NSString * post_url;
@property (nonatomic, strong) NSString * reblog_key;
@property (nonatomic, strong) NSString * track_name;
@property (nonatomic, strong) Blog *blog;

@end

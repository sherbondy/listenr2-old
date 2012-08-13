//
//  Blog.h
//  listenr
//
//  Created by Ethan Sherbondy on 8/12/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Blog : NSManagedObject

@property (nonatomic, retain) NSString * blogDescription;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * posts;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * following;
@property (nonatomic, retain) NSManagedObject *songs;

// transforms the dictionary output of a blog request into a blog
+ (id)blogForData:(NSDictionary *)blogData;

- (NSURL *)avatarURL;

@end

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

@property (nonatomic, strong) NSString * blogDescription;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * posts;
@property (nonatomic, strong) NSDate * updated;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSNumber * following;
@property (nonatomic, strong) NSSet    * songs;
@property (nonatomic, strong) NSNumber * favorite;

// transforms the dictionary output of a blog request into a blog
+ (id)blogForAttrs:(NSDictionary *)blogAttrs;

- (NSURL *)avatarURL;

@end

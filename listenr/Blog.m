//
//  Blog.m
//  listenr
//
//  Created by Ethan Sherbondy on 8/12/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import "Blog.h"
#import "AppDelegate.h"
#import "TumblrAPI.h"
#import "NSManagedObject+Additions.h"

@implementation Blog

@dynamic blogDescription;
@dynamic name;
@dynamic posts;
@dynamic updated;
@dynamic url;
@dynamic following;
@dynamic songs;

- (NSURL *)avatarURL
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@blog/%@/avatar/96",
                                             kTumblrAPIBaseURLString, [TumblrAPI blogHostname:self.name]]];
}

+ (id)blogForAttrs:(NSDictionary *)blogAttrs {
    Blog *blog = [Blog objectWithAttrs:blogAttrs];
    
    NSString *blogDescription = [blogAttrs objectForKey:@"description"];
    if (blogDescription){
        [blog setValue:blogDescription forKey:@"blogDescription"];
    }

    return blog;
}

@end

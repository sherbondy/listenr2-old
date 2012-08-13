//
//  Blog.m
//  listenr
//
//  Created by Ethan Sherbondy on 8/12/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import "Blog.h"
#import "AppDelegate.h"

@implementation Blog

@dynamic blogDescription;
@dynamic name;
@dynamic posts;
@dynamic updated;
@dynamic url;
@dynamic following;
@dynamic songs;

// Saving updated (NSDate) does not work right now. Bug in Core Data?

+ (id)transformValue:(id)value toType:(NSAttributeType)attributeType
{    
    id transformedValue;
    
    if (attributeType >= NSInteger16AttributeType && attributeType <= NSFloatAttributeType) {
        if ([value isKindOfClass:[NSString self]]){
            transformedValue = [[NSNumberFormatter new] numberFromString:value];
        }
    } else if (attributeType == NSDateAttributeType){
        // only handles timestamps
        transformedValue = [NSDate dateWithTimeIntervalSince1970:[value longValue]];
    }
    
    if (!transformedValue){
        transformedValue = value;
    }
    return transformedValue;
}

+ (id)blogForData:(NSDictionary *)blogData {
    NSManagedObjectContext *moc = [AppDelegate moc];
    NSEntityDescription *description = [NSEntityDescription entityForName:NSStringFromClass([Blog class])
                                                   inManagedObjectContext:moc];
    NSDictionary *attributes = [description attributesByName];
    Blog *blog = [[Blog alloc] initWithEntity:description insertIntoManagedObjectContext:moc];

    for (id key in blogData){
        id value = [blogData objectForKey:key];
        NSAttributeDescription *attribute = [attributes objectForKey:key];
        value = [Blog transformValue:value toType:[attribute attributeType]];
        
        if ([key isEqualToString:@"description"]){
            [blog setValue:value forKey:@"blogDescription"];
        } else {
            if ([attributes objectForKey:key]){
                [blog setValue:value forKey:key];
            }
        }
    }

    return blog;
}

@end

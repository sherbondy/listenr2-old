//
//  NSManagedObject+Additions.m
//  listenr
//
//  Created by Ethan Sherbondy on 8/13/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import "NSManagedObject+Additions.h"
#import "AppDelegate.h"

@implementation NSManagedObject (Additions)

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

+ (id)objectWithAttrs:(NSDictionary *)attrs
{
    NSManagedObjectContext *moc = [AppDelegate moc];
    NSEntityDescription *description = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                                   inManagedObjectContext:moc];
    NSManagedObject *managedObject = [[self alloc] initWithEntity:description insertIntoManagedObjectContext:moc];
    NSDictionary *attributes = [managedObject.entity attributesByName];
    
    for (id key in attrs){
        id value = [attrs objectForKey:key];
        NSAttributeDescription *attribute = [attributes objectForKey:key];
        value = [self transformValue:value toType:[attribute attributeType]];
        
        if ([attributes objectForKey:key]){
            [managedObject setValue:value forKey:key];
        }
    }
    
    return managedObject;
}

@end

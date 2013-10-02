//
//  NSManagedObject+Additions.h
//  listenr
//
//  Created by Ethan Sherbondy on 8/13/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

@interface NSManagedObject (Additions)

+ (id)transformValue:(id)value toType:(NSAttributeType)attributeType;
+ (id)objectWithAttrs:(NSDictionary *)attrs;

@end

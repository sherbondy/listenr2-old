//
//  NSManagedObjectContext+Additions.h
//  listenr
//
//  Created by Ethan Sherbondy on 8/12/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Additions)

- (NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName
                       withPredicate:(id)stringOrPredicate, ...;

@end
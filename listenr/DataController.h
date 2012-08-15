//
//  DataController.h
//  listenr
//
//  Created by Ethan Sherbondy on 8/14/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataController : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext       *moc;
@property (readonly, strong, nonatomic) NSManagedObjectModel         *mom;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *psc;

+ (id)sharedController;

- (void)saveContext;
- (NSURL *)appDocDir;

@end

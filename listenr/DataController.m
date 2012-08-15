//
//  DataController.m
//  listenr
//
//  Created by Ethan Sherbondy on 8/14/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import "DataController.h"

@implementation DataController

@synthesize moc = _moc;
@synthesize mom = _mom;
@synthesize psc = _psc;

+ (id)sharedController
{
    static DataController *sharedController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedController){
            sharedController = [[DataController alloc] init];
        }
    });
    return sharedController;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *moc = self.moc;
    if (moc != nil) {
        if ([moc hasChanges] && ![moc save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)moc
{
    if (_moc != nil) {
        return _moc;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self psc];
    if (coordinator != nil) {
        _moc = [[NSManagedObjectContext alloc] init];
        [_moc setPersistentStoreCoordinator:coordinator];
    }
    return _moc;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)mom
{
    if (_mom != nil) {
        return _mom;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"listenr" withExtension:@"momd"];
    _mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _mom;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)psc
{
    if (_psc != nil) {
        return _psc;
    }
    
    NSURL *storeURL = [[self appDocDir] URLByAppendingPathComponent:@"listenr.sqlite"];
    
    NSError *error = nil;
    _psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self mom]];
    if (![_psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _psc;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)appDocDir
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

//
//  SongsVC.h
//  
//
//  Created by Ethan Sherbondy on 8/13/12.
//
//

#import <UIKit/UIKit.h>

@class Blog;

@interface SongsVC : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, readonly, strong) NSFetchedResultsController *songsController;
@property (nonatomic, readonly, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, readonly, strong) Blog *source;

- (id)initWithSource:(Blog *)source;

@end
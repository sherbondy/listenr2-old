//
//  SongsVC.h
//  
//
//  Created by Ethan Sherbondy on 8/13/12.
//
//

#import <UIKit/UIKit.h>
#import "AudioPlayerVC.h"

@class Blog;
@class Song;

@interface SongsVC : UITableViewController <NSFetchedResultsControllerDelegate, AudioPlayerDatasource>

@property (nonatomic, readonly, strong) NSFetchedResultsController *songsController;
@property (nonatomic, readonly, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, readonly, strong) Blog *source;
@property (nonatomic, readonly)         Song *currentSong;

- (id)initWithSource:(Blog *)source;

@end

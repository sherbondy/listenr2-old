//
//  SongsVC.m
//  
//
//  Created by Ethan Sherbondy on 8/13/12.
//
//

#import "SongsVC.h"
#import "Blog.h"
#import "Song.h"
#import "AppDelegate.h"
#import "TumblrAPI.h"
#import "NSManagedObjectContext+Additions.h"
#import <AVFoundation/AVFoundation.h>

@interface SongsVC ()
@end

@implementation SongsVC

+ (AVPlayer *)sharedPlayer
{
    static AVPlayer *player;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[AVPlayer alloc] init];
    });
    return player;
}

- (id)initWithSource:(Blog *)source
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _source = source;
    }
    return self;
}

- (void)fetch
{
    NSError *error;
    [_songsController performFetch:&error];
    if (error){
        NSLog(@"Error: %@", [error description]);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *blogName = self.source.name;

    self.title = blogName;
    
    [[SongsVC sharedPlayer] addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

    _fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
    // Make it possible to sort by song name too!
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO]; // sort by post date
    _fetchRequest.sortDescriptors = @[sortDescriptor];
    _fetchRequest.predicate = [NSPredicate predicateWithFormat:@"blog.name == %@", blogName];
        
    _songsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_fetchRequest managedObjectContext:[AppDelegate moc]
                                                             sectionNameKeyPath:nil cacheName:nil];
    _songsController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetch];
    
    // grab the latest data from the blog
    [[TumblrAPI sharedClient] blogPosts:self.source.name success:^(NSArray *posts) {
        [[AppDelegate sharedDelegate] saveContext];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Request failed: %@", [error description]);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0){
        return [_songsController fetchedObjects].count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SongCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Song *song = [self.songsController objectAtIndexPath:indexPath];
    NSString *defaultTrackName = @"Unknown Song";
    NSString *defaultArtist = @"Unknown Artist";
    NSString *defaultAlbum = @"Unknown Album";
    cell.textLabel.text = song.track_name ? song.track_name : defaultTrackName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", (song.artist ? song.artist : defaultArtist), (song.album ? song.album : defaultAlbum)];
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:song.album_art] placeholderImage:[UIImage imageNamed:@"default_avatar"]];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    Song *song = [_songsController objectAtIndexPath:indexPath];
    NSLog(@"%@", song.audio_url);
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[song trueAudioURL]];
    [[SongsVC sharedPlayer] replaceCurrentItemWithPlayerItem:item];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[AVPlayer self]]){
        
        if ([[change objectForKey:@"new"] intValue] == AVPlayerStatusReadyToPlay){
            NSLog(@"Time to play!");
            AVPlayer *player = object;
            [player play];
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert){
        [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (type == NSFetchedResultsChangeDelete){
        [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] endUpdates];
}

@end

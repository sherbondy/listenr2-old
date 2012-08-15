//
//  SongsVC.m
//  
//
//  Created by Ethan Sherbondy on 8/13/12.
//
//

#import "AudioPlayerVC.h"
#import "SongsVC.h"
#import "Blog.h"
#import "Song.h"
#import "DataController.h"
#import "TumblrAPI.h"
#import "NSManagedObjectContext+Additions.h"

@interface SongsVC ()
- (void)downloadSongs;
- (void)pushPlayer;
@end

@implementation SongsVC

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

- (void)downloadSongsWithOffset:(NSUInteger)offset
{
    // grab the latest data from the blog
    [[TumblrAPI sharedClient] blogPosts:self.source.name success:^(NSArray *posts) {
        [[DataController sharedController] saveContext];
        [self.refreshControl endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Request failed: %@", [error description]);
        [self.refreshControl endRefreshing];
    }];
}

- (void)downloadSongs
{
    if (!self.refreshControl.isRefreshing){
        [self.refreshControl beginRefreshing];
    }
    [self downloadSongsWithOffset:0];
}

- (void)pushPlayer
{
    [[self navigationController] pushViewController:[AudioPlayerVC sharedVC] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *blogName = self.source.name;

    self.title = blogName;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    [self.refreshControl addTarget:self action:@selector(downloadSongs) forControlEvents:UIControlEventValueChanged];
    
    _fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
    // Make it possible to sort by song name too!
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO]; // sort by post date
    _fetchRequest.sortDescriptors = @[sortDescriptor];
    _fetchRequest.predicate = [NSPredicate predicateWithFormat:@"blog.name == %@", blogName];
        
    _songsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_fetchRequest managedObjectContext:[[DataController sharedController] moc]
                                                             sectionNameKeyPath:nil cacheName:nil];
    _songsController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[AudioPlayerVC sharedVC] currentSong]){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"NP" style:UIBarButtonItemStyleBordered
                                                                                 target:self action:@selector(pushPlayer)];
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor blackColor]];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self fetch];
    [self downloadSongs];
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
    cell.textLabel.text = song.track_name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", song.artist, song.album];
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:song.album_art] placeholderImage:[UIImage imageNamed:@"default_avatar"]];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *song = [_songsController objectAtIndexPath:indexPath];
    _currentSong = song;
    _currentSongIndex = indexPath.row;
    [[AudioPlayerVC sharedVC] setDatasource:self];
    [self pushPlayer];
    [[AudioPlayerVC sharedVC] playNewTrack];
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

# pragma mark - AudioPlayerDatasource methods

- (BOOL)hasPrevious {
    return (_currentSongIndex > 0);
}

- (BOOL)hasNext {
    return (_currentSongIndex < (_songsController.fetchedObjects.count - 1));
}

typedef NSInteger (*PrevNextPtr)(NSInteger, NSFetchedResultsController*);

NSInteger prevSongRowFn(NSInteger index, NSFetchedResultsController *controller) {
    return MAX(0, index - 1);
}
NSInteger nextSongRowFn(NSInteger index, NSFetchedResultsController *controller) {
    return MIN((controller.fetchedObjects.count - 1), index + 1);
}

- (NSIndexPath *)prevOrNextIndex:(PrevNextPtr)prevNextFn {
    return [NSIndexPath indexPathForRow:prevNextFn(_currentSongIndex, _songsController) inSection:0];
}

- (void)playPrevOrNext:(PrevNextPtr)prevNextFn {
    NSIndexPath *prevOrNextIndex = [self prevOrNextIndex:prevNextFn];
    _currentSongIndex = prevOrNextIndex.row;
    _currentSong = [_songsController objectAtIndexPath:prevOrNextIndex];
    [[AudioPlayerVC sharedVC] playNewTrack];
}

- (void)playPrevious {
    [self playPrevOrNext:prevSongRowFn];
}
- (void)playNext {
    [self playPrevOrNext:nextSongRowFn];
}

- (Song *)prevOrNextSong:(PrevNextPtr)prevNextFn {
    return [_songsController objectAtIndexPath:[self prevOrNextIndex:prevNextFn]];
}

- (Song *)previousSong {
    return [self prevOrNextSong:prevSongRowFn];
}

- (Song *)nextSong {
    return [self prevOrNextSong:nextSongRowFn];
}

@end

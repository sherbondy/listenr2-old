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

@property (nonatomic, readwrite, strong) NSIndexPath *currentIndexPath;
@end

static NSArray *scopeButtonTitles;
static NSArray *searchTypes;

@implementation SongsVC

+ (void)initialize
{
    scopeButtonTitles = @[@"Title", @"Artist", @"Album"];
    searchTypes       = @[@"track_name", @"artist", @"album"];
}

- (id)initWithSource:(Blog *)source
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _source = source;
    }
    return self;
}


#pragma mark - Query party

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

- (void)makeFetchRequestStandard
{
    self.songsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"blog.name == %@", self.source.name];
}

- (void)makeFetchRequestSearch:(NSString *)query
{
    // cd = case and diacritic insensitive
    NSString *cleanQuery = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    // Don't start querying until there are 3+ characters
    if (cleanQuery.length > 2) {
        NSInteger selectedIndex = self.searchDisplayController.searchBar.selectedScopeButtonIndex;
        self.songsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:
                                                       [NSString stringWithFormat:@"%@ contains[cd] '%@'", searchTypes[selectedIndex], cleanQuery, nil]];
    }
}


#pragma mark - View Lifecycle

- (void)pushPlayer
{
    [[self navigationController] pushViewController:[AudioPlayerVC sharedVC] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.source.name;
    
    /* Set left arrow for when we push the AudioPlayerVC.
       This isn't the CURRENT back button, it's a hypothetical back button
       that will be used for the next view controller pushed onto the stack */
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    [backButton setTitle:@""];
    self.navigationItem.backBarButtonItem = backButton;

    
    // refresh setup
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    [self.refreshControl addTarget:self action:@selector(downloadSongs) forControlEvents:UIControlEventValueChanged];
    
    // search bar setup
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    searchBar.placeholder = @"Search for Song";
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.scopeButtonTitles = scopeButtonTitles;
    [searchBar sizeToFit];
    self.tableView.tableHeaderView = searchBar;
    
    // search display controller setup
    self.songSearchDC = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.songSearchDC.delegate = self;
    self.songSearchDC.searchResultsDelegate = self;
    self.songSearchDC.searchResultsDataSource = self;

    
    _fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
    // Make it possible to sort by song name too!
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO]; // sort by post date
    _fetchRequest.sortDescriptors = @[sortDescriptor];
    
    _songsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_fetchRequest
                                                           managedObjectContext:[[DataController sharedController] moc]
                                                             sectionNameKeyPath:nil cacheName:nil];
    [self makeFetchRequestStandard];
    _songsController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView setContentOffset:CGPointMake(0, 44)];
        
    if ([[AudioPlayerVC sharedVC] currentSong]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"NP" style:UIBarButtonItemStyleBordered
                                                                                 target:self action:@selector(pushPlayer)];
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor blackColor]];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    if (self.currentIndexPath) {
        [self.tableView scrollToRowAtIndexPath:self.currentIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    
    self.navigationController.navigationBar.barTintColor = [UIColor purpleColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
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
        
        UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        testView.backgroundColor = [UIColor blueColor];
        [cell setAccessoryView:testView];
        cell.accessoryView.hidden = YES;
    }
    
    @try {
        Song *song = [self.songsController objectAtIndexPath:indexPath];
        cell.textLabel.text = song.track_name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", song.artist, song.album];
        [cell.imageView setImageWithURL:[NSURL URLWithString:song.album_art] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
        
        cell.accessoryView.hidden = ![song isEqualToSong:self.currentSong];
    } @catch (NSException *e) {
        NSLog(@"Damn you, NSInternalInconsistency Exception.");
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *song = [self.songsController objectAtIndexPath:indexPath];
    _currentSong = song;
    self.currentIndexPath = indexPath;
    [[AudioPlayerVC sharedVC] setDatasource:self];
    [self pushPlayer];
    [[AudioPlayerVC sharedVC] playNewTrack];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert){
        [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (type == NSFetchedResultsChangeDelete){
        [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        NSLog(@"Unexpected results change");
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

# pragma mark - UISearchDisplayController gunk

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self makeFetchRequestStandard];
    [self fetch];
}

# pragma mark - UISearchBar delegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self makeFetchRequestSearch:searchText];
    [self fetch];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self makeFetchRequestSearch:searchBar.text];
    [self fetch];
}

# pragma mark - AudioPlayerDatasource methods

- (BOOL)hasPrevious {
    return (self.currentIndexPath.row > 0);
}

- (BOOL)hasNext {
    return (self.currentIndexPath.row < (_songsController.fetchedObjects.count - 1));
}

typedef NSInteger (*PrevNextPtr)(NSUInteger, NSFetchedResultsController*);

- (NSIndexPath *)prevOrNextIndex:(PrevNextPtr)prevNextFn {
    return [NSIndexPath indexPathForRow:prevNextFn(self.currentIndexPath.row, _songsController) inSection:0];
}

- (void)playPrevOrNext:(PrevNextPtr)prevNextFn {
    NSIndexPath *prevOrNextIndex = [self prevOrNextIndex:prevNextFn];
    _currentSong = [_songsController objectAtIndexPath:prevOrNextIndex];
    self.currentIndexPath = prevOrNextIndex;
    
    [[AudioPlayerVC sharedVC] playNewTrack];
}

NSInteger prevSongRowFn(NSUInteger index, NSFetchedResultsController *controller) {
    return MAX(0, index - 1);
}
- (void)playPrevious {
    [self playPrevOrNext:prevSongRowFn];
}

NSInteger nextSongRowFn(NSUInteger index, NSFetchedResultsController *controller) {
    return MIN((controller.fetchedObjects.count - 1), index + 1);
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

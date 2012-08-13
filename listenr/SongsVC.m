//
//  SongsVC.m
//  
//
//  Created by Ethan Sherbondy on 8/13/12.
//
//

#import "SongsVC.h"
#import "Blog.h"
#import "AppDelegate.h"
#import "TumblrAPI.h"

@interface SongsVC ()
@end

@implementation SongsVC

+ (id)sharedVC
{
    static dispatch_once_t pred;
    static SongsVC *_sharedVC;
    
    dispatch_once(&pred, ^{
        _sharedVC = [[self alloc] initWithStyle:UITableViewStylePlain];
    });
    return _sharedVC;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setSource:(Blog *)source
{
    NSError *error;

    NSString *blogName = source.name;
    self.title = blogName;
    
    // grab the latest data from the blog
    [[TumblrAPI sharedClient] blogPosts:blogName success:nil failure:nil];

    _fetchRequest.predicate = [NSPredicate predicateWithFormat:@"blog.name == %@", blogName];
    [_songsController performFetch:&error];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
    // Make it possible to sort by song name too!
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]; // sort by post date
    _fetchRequest.sortDescriptors = @[sortDescriptor];
    
    // Not wise to use a cache here since we're changing the songs so frequently.
    _songsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_fetchRequest managedObjectContext:[AppDelegate moc]
                                                            sectionNameKeyPath:nil cacheName:nil];
    _songsController.delegate = self;
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
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
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
}

@end

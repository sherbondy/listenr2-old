//
//  HomeVC.m
//  listenr
//
//  Created by Ethan Sherbondy on 8/11/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import "HomeVC.h"
#import "AddBlogVC.h"
#import "Blog.h"
#import "SongsVC.h"
#import "DataController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation HomeVC

- (id)init {
    self = [super init];
    AddBlogVC *addVC = [[AddBlogVC alloc] initWithStyle:UITableViewStyleGrouped];
    
    _addNav = [[UINavigationController alloc] initWithRootViewController:addVC];
    return self;
}

- (NSString *)title { return @"Listenr"; }

- (void)logout {
    
}

- (void)add {
    [self presentViewController:self.addNav animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered
                                                                            target:self action:@selector(logout)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self action:@selector(add)];
    
    NSFetchRequest *fetchFavoriteBlogs = [NSFetchRequest fetchRequestWithEntityName:@"Blog"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]; // sort by blog name
    fetchFavoriteBlogs.sortDescriptors = @[sortDescriptor];
    fetchFavoriteBlogs.predicate = [NSPredicate predicateWithFormat:@"favorite == %@", @(YES)];
    
    // should probably set a cache eventually, in which case I'll need to call deleteCache at the proper times.
    _blogController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchFavoriteBlogs
                                                          managedObjectContext:[[DataController sharedController] moc]
                                                            sectionNameKeyPath:nil cacheName:@"BlogCache"];
    _blogController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    NSError *fetchError;
    [_blogController performFetch:&fetchError];
    
    NSIndexPath *selectedRow = [[self tableView] indexPathForSelectedRow];
    if (selectedRow){
        [[self tableView] deselectRowAtIndexPath:selectedRow animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        return [_blogController fetchedObjects].count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *BlogCellID = @"BlogCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BlogCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:BlogCellID];
    }
    
    Blog *blog = [_blogController objectAtIndexPath:indexPath];
    cell.textLabel.text = blog.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    [cell.imageView setImageWithURL:[blog avatarURL] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete){
        [[_blogController managedObjectContext] deleteObject:[_blogController objectAtIndexPath:indexPath]];
    }
    [[DataController sharedController] saveContext];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Blog *source = [_blogController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:[[SongsVC alloc] initWithSource:source] animated:YES];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert){
        [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (type == NSFetchedResultsChangeDelete){
        [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end

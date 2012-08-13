//
//  HomeVC.m
//  listenr
//
//  Created by Ethan Sherbondy on 8/11/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import "HomeVC.h"
#import "AddBlogViewController.h"
#import "AppDelegate.h"
#import "Blog.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation HomeVC

- (id)init {
    self = [super init];
    AddBlogViewController *addVC = [[AddBlogViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    self.addNav = [[UINavigationController alloc] initWithRootViewController:addVC];
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
    
    NSFetchRequest *fetchAllBlogs = [NSFetchRequest fetchRequestWithEntityName:@"Blog"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]; // sort by blog name
    fetchAllBlogs.sortDescriptors = @[sortDescriptor];
    
    // should probably set a cache eventually, in which case I'll need to call deleteCache at the proper times.
    _blogController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchAllBlogs managedObjectContext:[AppDelegate moc]
                                                            sectionNameKeyPath:nil cacheName:nil];
    _blogController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    NSError *fetchError;
    [_blogController performFetch:&fetchError];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BlogCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BlogCell"];
    }
    
    Blog *blog = [_blogController objectAtIndexPath:indexPath];
    cell.textLabel.text = blog.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    [cell.imageView setImageWithURL:[blog avatarURL] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    NSLog(@"%@", blog.url);
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
    [[AppDelegate sharedDelegate] saveContext];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // should implement other NSFetchedResultsControllerDelegate methods for finer control
    [[self tableView] reloadData];
}

@end

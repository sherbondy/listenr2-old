//
//  HomeVC.m
//  listenr
//
//  Created by Ethan Sherbondy on 8/11/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import "HomeVC.h"
#import "AddBlogViewController.h"

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
}

@end

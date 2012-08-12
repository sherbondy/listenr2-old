//
//  HomeVC.m
//  listenr
//
//  Created by Ethan Sherbondy on 8/11/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import "HomeVC.h"

@implementation HomeVC

- (NSString *)title { return @"Listenr"; }

- (void)logout {
    
}

- (void)add {
    
}

- (void)viewDidLoad {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
}

@end

//
//  HomeVC.h
//  listenr
//
//  Created by Ethan Sherbondy on 8/11/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeVC : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) UINavigationController *addNav;
@property (nonatomic, retain) NSFetchedResultsController *blogController;

@end

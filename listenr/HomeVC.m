//
//  HomeVC.m
//  listenr
//
//  Created by Ethan Sherbondy on 8/11/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import "HomeVC.h"
#import "UIColor+Additions.h"
#import "TumblrAPI.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <JMStaticContentTableViewController/JMStaticContentTableViewController.h>
#import <QuartzCore/QuartzCore.h>

@interface AddBlogVC : JMStaticContentTableViewController <UITextFieldDelegate>

@property (nonatomic, retain) UISwitch    *followSwitch;
@property (nonatomic, retain) UITextField *blogNameField;
@property (nonatomic, retain) NSTimer     *blogInfoTimer;
@property (nonatomic, retain) NSDate      *lastEditTime;
@property (nonatomic, retain) NSString    *lastBlogName;


@end

@implementation AddBlogVC

- (NSString *)title { return @"Add Blog"; }

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)done {
    // show spinner
    [[TumblrAPI sharedClient] blogInfo:self.blogNameField.text success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YES;
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.navigationItem.rightBarButtonItem.enabled) {
        [self done];
    }
    return YES;
}

- (NSString *)trueBlogName {
    return [_blogNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void)toggleDoneEnabled {
    [self.navigationItem.rightBarButtonItem setEnabled:([self trueBlogName].length > 0)];
}

- (void)showBlogInfo {
    NSString *trueBlogName = [self trueBlogName];
    NSTimeInterval timeDelta = [[NSDate date] timeIntervalSinceDate:self.lastEditTime];
    if ( (![self.lastBlogName isEqual:trueBlogName]) &&
         (trueBlogName.length > 0) && timeDelta > 1) {
        
        self.lastBlogName = trueBlogName;
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:1];
        
        [self.tableView beginUpdates];
        
        if ([self.tableView cellForRowAtIndexPath:path]){
            [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
            [[self.staticContentSections objectAtIndex:1] removeAllCells];
        }
        
        [[TumblrAPI sharedClient] blogInfo:trueBlogName success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *blog = [[responseObject objectForKey:@"response"] objectForKey:@"blog"];
            
            [self insertCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
                staticContentCell.reuseIdentifier = @"UserInfoCell";
                staticContentCell.cellStyle = UITableViewCellStyleSubtitle;
                cell.textLabel.text = [blog objectForKey:@"title"];
                cell.detailTextLabel.text = [blog objectForKey:@"url"];
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                
                NSURL *avatarURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@blog/%@/avatar/96",
                                                         kTumblrAPIBaseURLString, [TumblrAPI blogHostname:trueBlogName]]];
                [cell.imageView setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"default_avatar"]];
                cell.imageView.layer.cornerRadius = 8.0f;
                cell.imageView.layer.masksToBounds = YES;
            } atIndexPath:path animated:YES];
            [self.tableView endUpdates];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self insertCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
                staticContentCell.reuseIdentifier = @"UserInfoCell";
                cell.textLabel.text = @"Could not find blog.";
                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.imageView.image = nil;
            } atIndexPath:path animated:YES];
            [self.tableView endUpdates];
        }];
    }
}

- (void)textFieldChanged {
    [self toggleDoneEnabled];
    self.lastEditTime = [NSDate date];
}

- (void)customizeBlogNameField {
    _blogNameField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _blogNameField.textColor = [UIColor blueTextColor];
    _blogNameField.enablesReturnKeyAutomatically = YES;
    _blogNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _blogNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    _blogNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _blogNameField.returnKeyType = UIReturnKeyGo;
    _blogNameField.placeholder = @"yvynyl";
    _blogNameField.delegate = self;
    [self toggleDoneEnabled];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self action:@selector(done)];
        
    _followSwitch = [[UISwitch alloc] init];
    _blogNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 160, 24)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged) name:UITextFieldTextDidChangeNotification object:_blogNameField];
    
    [self customizeBlogNameField];
    
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleDefault;
            staticContentCell.reuseIdentifier = @"BlogNameCell";
            cell.textLabel.text = @"Blog Name";
            cell.accessoryView = self.blogNameField;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }];
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleDefault;
            staticContentCell.reuseIdentifier = @"FollowCell";
            cell.textLabel.text = @"Follow?";
            cell.accessoryView = self.followSwitch;
        }];
    }];
    
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        YES;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.blogNameField becomeFirstResponder];
    
    // this timer pulls blog info periodically if the text field hasn't been changed in the past second and the blog name is new.
    _blogInfoTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(showBlogInfo) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_blogInfoTimer forMode:NSRunLoopCommonModes];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_blogInfoTimer invalidate];
}

@end



@implementation HomeVC

- (id)init {
    self = [super init];
    AddBlogVC *addVC = [[AddBlogVC alloc] initWithStyle:UITableViewStyleGrouped];
    
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

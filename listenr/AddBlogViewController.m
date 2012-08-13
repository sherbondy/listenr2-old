//
//  AddBlogViewController.m
//  listenr
//
//  Created by Ethan Sherbondy on 8/12/12.
//  Copyright (c) 2012 Unidextrous. All rights reserved.
//

#import "AddBlogViewController.h"
#import "UIColor+Additions.h"
#import "TumblrAPI.h"
#import "Blog.h"
#import "AppDelegate.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <JMStaticContentTableViewController/JMStaticContentTableViewController.h>
#import <QuartzCore/QuartzCore.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface AddBlogViewController()

@property (nonatomic, retain) UISwitch    *followSwitch;
@property (nonatomic, retain) UITextField *blogNameField;
@property (nonatomic, retain) NSTimer     *blogInfoTimer;
@property (nonatomic, retain) NSDate      *lastEditTime;
@property (nonatomic, retain) NSString    *lastBlogName;

@end

@implementation AddBlogViewController

// @TODO: Make follow button do something. Proactively store blog info in the database.

- (NSString *)title { return @"Add Blog"; }

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)done {
    // show spinner
    NSString *blogName = [self trueBlogName];
    
    [SVProgressHUD showWithStatus:@"Verifying Blog Exists"];
    [[TumblrAPI sharedClient] blogInfo:blogName success:^(Blog *blog){
        [[AppDelegate sharedDelegate] saveContext];
        [SVProgressHUD dismissWithSuccess:[NSString stringWithFormat:@"%@ Added", blogName]];
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismissWithError:@"Could not find blog."];
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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSURL *blogURL = [NSURL URLWithString:[@"http://" stringByAppendingString:[TumblrAPI blogHostname:self.lastBlogName]]];
    [[UIApplication sharedApplication] openURL:blogURL];
}

- (void)hideBlogInfo {
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:1];
    
    if ([self.tableView cellForRowAtIndexPath:path]){
        [[self.staticContentSections objectAtIndex:1] removeAllCells];
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)showBlogInfo {
    NSString *trueBlogName = [self trueBlogName];
    NSTimeInterval timeDelta = [[NSDate date] timeIntervalSinceDate:self.lastEditTime];
    if ( (![self.lastBlogName isEqual:trueBlogName]) &&
        (trueBlogName.length > 0) && timeDelta > 1) {
        
        self.lastBlogName = trueBlogName;
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:1];
        
        [self.tableView beginUpdates];
        [self hideBlogInfo];
        
        [[TumblrAPI sharedClient] blogInfo:trueBlogName success:^(Blog *blog) {            
            [self insertCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
                staticContentCell.reuseIdentifier = @"UserInfoCell";
                staticContentCell.cellStyle = UITableViewCellStyleSubtitle;
                cell.textLabel.text = blog.name;
                cell.detailTextLabel.text = blog.url;
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                [cell.imageView setImageWithURL:[blog avatarURL] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
                cell.imageView.layer.cornerRadius = 8.0f;
                cell.imageView.layer.masksToBounds = YES;
            } atIndexPath:path animated:YES];
            [self.tableView endUpdates];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self insertCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
                staticContentCell.reuseIdentifier = @"UserInfoCell";
                cell.textLabel.text = [NSString stringWithFormat:@"Could not find %@.", trueBlogName];
                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.imageView.image = nil;
            } atIndexPath:path animated:YES];
            [self.tableView endUpdates];
        }];
    } else if ([self trueBlogName].length == 0){
        [self hideBlogInfo];
        self.lastBlogName = nil;
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
    _blogInfoTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(showBlogInfo) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_blogInfoTimer forMode:NSRunLoopCommonModes];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_blogInfoTimer invalidate];
    [self hideBlogInfo];
    _blogNameField.text = @"";
    _lastBlogName = nil;
}

@end
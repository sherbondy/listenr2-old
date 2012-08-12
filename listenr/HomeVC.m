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

#import <JMStaticContentTableViewController/JMStaticContentTableViewController.h>

@interface AddBlogVC : JMStaticContentTableViewController <UITextFieldDelegate>

@property (nonatomic, retain) UISwitch    *followSwitch;
@property (nonatomic, retain) UITextField *blogNameField;

@end

@implementation AddBlogVC

- (NSString *)title { return @"Add Blog"; }

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)done {
    [[TumblrAPI sharedClient] blogInfo:self.blogNameField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.navigationItem.rightBarButtonItem.enabled){
        [self done];
    }
    return YES;
}

- (void)toggleDoneEnabled {
    NSString *blogName = [_blogNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self.navigationItem.rightBarButtonItem setEnabled:(blogName.length > 0)];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleDoneEnabled) name:UITextFieldTextDidChangeNotification object:_blogNameField];
    
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.blogNameField becomeFirstResponder];
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

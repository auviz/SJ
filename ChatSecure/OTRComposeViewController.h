//
//  OTRComposeViewController.h
//  Off the Record
//
//  Created by David Chiles on 3/4/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YapDatabaseViewMappings.h"


@class OTRBuddy;
@class OTRComposeViewController;

@protocol OTRComposeViewControllerDelegate <NSObject>

- (void)controller:(OTRComposeViewController *)viewController didSelectBuddy:(OTRBuddy *)buddy;

@end

@interface OTRComposeViewController : UIViewController {
    BOOL *  _isEditing;
    
    NSMutableDictionary * _selectedItems;
}

-(void)goChatWithNewRoom:(NSString *)roomID;
-(id)initWithHidenTabBar;


- (OTRBuddy *)buddyAtIndexPath:(NSIndexPath *)indexPath;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)cancelButtonPressed:(id)sender;


@property (nonatomic, weak) id<OTRComposeViewControllerDelegate> delegate;

//Zig
- (BOOL)useSearchResults;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) YapDatabaseViewMappings *mappings;
@property (nonatomic) BOOL hideTabBar;


@end

//
//  OTRConversationViewController.h
//  Off the Record
//
//  Created by David Chiles on 3/2/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTRMessagesViewController.h"

@class OTRBuddy;

@interface OTRConversationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (void)enterConversationWithBuddy:(OTRBuddy *)buddy;
- (void)composeButtonPressed:(id)sender;
- (void)settingsButtonPressed:(id)sender;
-(OTRMessagesViewController *)messagesViewControllerWithBuddy:(OTRBuddy *)buddy;
- (void)enterConversationWithBuddyNoAnimition:(OTRBuddy *)buddy;

@end

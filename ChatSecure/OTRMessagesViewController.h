//
//  OTRMessagesViewController.h
//  Off the Record
//
//  Created by David Chiles on 5/12/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessagesViewController.h"
#import "OTRMessage.h"


@class OTRBuddy, OTRXMPPManager, OTRAccount;

@interface OTRMessagesViewController : JSQMessagesViewController <UISplitViewControllerDelegate> {
    
    BOOL * _isGroupChat;
    
}

@property (nonatomic, strong) OTRBuddy *buddy;
@property (nonatomic, weak) OTRXMPPManager *xmppManager;

//Send photo
-(void)sendUidPhoto:(OTRMessage *)selfMessage;
-(OTRMessage *)setPreviewUidPhoto:(NSString *)uid;
-(void)deleteMessage: (OTRMessage *)message;
-(void)initSendLocation;
//Mini actions
-(void)reloadDataForCollectionView;
@end

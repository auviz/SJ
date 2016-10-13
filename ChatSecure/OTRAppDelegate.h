//
//  OTRAppDelegate.h
//  Off the Record
//
//  Created by Chris Ballinger on 8/11/11.
//  Copyright (c) 2011 Chris Ballinger. All rights reserved.
//
//  This file is part of ChatSecure.
//
//  ChatSecure is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ChatSecure is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ChatSecure.  If not, see <http://www.gnu.org/licenses/>.

#import <UIKit/UIKit.h>
//#import "HockeySDK.h"
#import "SetGlobVar.h"
#import "updateApp.h" //zigzagcorp class
#import "OTRLocation.h"


#define MyLog if(0); else DDLogInfo;


@class OTRSettingsViewController;
@class OTRMessagesViewController;
@class OTRConversationViewController;
@class OTRComposeViewController;

@interface OTRAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) OTRSettingsViewController *settingsViewController;
@property (nonatomic, strong) OTRMessagesViewController *messagesViewController;
@property (nonatomic, strong) OTRConversationViewController *conversationViewController;
@property (nonatomic, strong) OTRComposeViewController * composeViewController;


@property (nonatomic, strong) NSTimer *backgroundTimer;

@property (nonatomic, strong) NSTimer *timerDSM;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic) BOOL didShowDisconnectionWarning;

@property (nonatomic) BOOL clearTasks;

//Push
@property (nonatomic, strong) NSString *deviceTokenString;
-(void)clearCount;
-(void)devOrProd:(NSString*)option;

- (void) showConversationViewController;

+ (OTRAppDelegate *)appDelegate;
+ (void)presentActionSheet:(UIActionSheet*)sheet inView:(UIView*)view;


//Delegate
@property(strong, nonatomic) id deleg;

- (id)delegate;

- (void)setDelegate:(id)newDelegate;

- (UIViewController*)defaultConversationNavigationController;



@end

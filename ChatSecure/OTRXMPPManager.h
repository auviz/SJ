//
//  OTRXMPPManager.h
//  Off the Record
//
//  Created by Chris Ballinger on 9/7/11.
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "OTRBuddy.h"
#import "XMPPFramework.h"
#import "XMPPReconnect.h"
#import "XMPPRoster.h"
#import "XMPPCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPCapabilities.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "OTRCodec.h"
#import "OTRProtocol.h"
#import "OTRXMPPBudyTimers.h"
#import "OTRCertificatePinning.h"
#import "OTRXMPPError.h"
#import "OTRConstants.h"

#import "XMPPRoom.h"
#import "XMPPRoomMemoryStorage.h"

#import "ZIGMyVCard.h"

@class OTRYapDatabaseRosterStorage;
@class OTRXMPPAccount;
@class OTRvCardYapDatabaseStorage;
@class OTRComposeViewController;

extern NSString *const OTRXMPPRegisterSucceededNotificationName;
extern NSString *const OTRXMPPRegisterFailedNotificationName;

@interface OTRXMPPManager : NSObject <XMPPRosterDelegate, NSFetchedResultsControllerDelegate, OTRProtocol, OTRCertificatePinningDelegate>

@property (nonatomic, readonly) XMPPStream *xmppStream;
@property (nonatomic, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, readonly) OTRYapDatabaseRosterStorage *xmppRosterStorage;
@property (nonatomic, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, readonly) OTRCertificatePinning * certificatePinningModule;
@property (nonatomic, readonly) BOOL isXmppConnected;
@property BOOL didSecure;
@property (nonatomic) BOOL isRoomError;

//MyVcard
@property (nonatomic, strong) ZIGMyVCard * myVCard;


@property NSArray * arrFriendsInGroup;
@property OTRComposeViewController* linkToOTRComposeViewController;

- (BOOL)connectWithJID:(NSString*) myJID password:(NSString*)myPassword;
- (void)disconnect;
-(void)goOffline;

- (NSString *)accountName;

- (void)registerNewAccountWithPassword:(NSString *)password;
- (void)failedToConnect:(NSError *)error;

- (void)createChatRoom:(NSString *) newRoomName;


- (void) sendInvite:(NSString*)buddyUsername roomID: (NSString* )roomID;
-(void) sendBye:(NSString*)buddyUsername roomID: (NSString* )roomID;

//Chat State
- (void)sendChatState:(OTRChatState)chatState withBuddyID:(NSString *)buddyUniqueId;
- (void)restartPausedChatStateTimerForBuddyObjectID:(NSString *)buddyUniqueId;
- (void)restartInactiveChatStateTimerForBuddyObjectID:(NSString *)buddyUniqueId;
- (void)invalidatePausedChatStateTimerForBuddyUniqueId:(NSString *)buddyUniqueId;
- (void)sendPausedChatState:(NSTimer *)timer;
- (void)sendInactiveChatState:(NSTimer *)timer;
- (NSTimer *)inactiveChatStateTimerForBuddyObjectID:(NSString *)buddyUniqueId;
- (NSTimer *)pausedChatStateTimerForBuddyObjectID:(NSString *)buddyUniqueId;
-(void)sendRenameRoom:(NSString*)buddyUsername roomID: (NSString* )roomID;
-(void) sendImAddFriend:(NSString*)buddyUsername roomID: (NSString* )roomID;
-(XMPPRoom *)getSJRooms:(NSString *)roomID;

-(void)deleteXmppRoom: (XMPPRoom *)room;
-(void)deleteSJRoomFromDic:(XMPPRoom *)room;

+(void)clearGroupChatNotGoodAttempts;

//Секурные
- (void)sendTimeMessage:(OTRMessage*)message timeOption:(NSString *)option;
-(void)sendIOpenSecurMessage:(OTRMessage *)mes buddyJID:(NSString *)JIDBuddy;
//Групповые сообщения из моего архива
@property (nonatomic, strong) NSTimer *timerMUCArchive;
-(void)receiveMessageForRoom:(NSString *)xmppMessage;
-(void)joinRoomById:(NSString *)roomID;
//Презенсы для группы
-(void)sendUpdateRoomPresence:(NSString *)roomId;

-(void)sendSubscribedToJid:(NSString *)jid;

@end

//
//  OTRXMPPManager.m
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

#import "OTRXMPPManager.h"

#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPMessage+XEP_0184.h"
#import "XMPPMessage+XEP_0085.h"
#import "NSXMLElement+XEP_0203.h"
#import "XMPPMessageDeliveryReceipts.h"
#import "Strings.h"
#import "OTRXMPPManagedPresenceSubscriptionRequest.h"
#import "OTRYapDatabaseRosterStorage.h"

#import "OTRLog.h"

#import <CFNetwork/CFNetwork.h>

#import "OTRSettingsManager.h"
#import "OTRConstants.h"
#import "OTRProtocolManager.h"
#include <stdlib.h>
#import "XMPPXFacebookPlatformAuthentication.h"
#import "XMPPXOAuth2Google.h"
#import "OTRConstants.h"
#import "OTRUtilities.h"

#import "OTRDatabaseManager.h"
#import "YapDatabaseConnection.h"
#import "OTRXMPPBuddy.h"
#import "OTRXMPPAccount.h"
#import "OTRMessage.h"
#import "OTRAccount.h"
#import "OTRXMPPPresenceSubscriptionRequest.h"
#import "OTRvCardYapDatabaseStorage.h"

#import "SetGlobVar.h"
#import "groupChatManager.h"
#import "OTRLocation.h"


#import "OTRComposeViewController.h"
#import "MUCArhive.h"
#import "historyManager.h"

NSString *const OTRXMPPRegisterSucceededNotificationName = @"OTRXMPPRegisterSucceededNotificationName";
NSString *const OTRXMPPRegisterFailedNotificationName    = @"OTRXMPPRegisterFailedNotificationName";

static NSString *const kOTRXMPPErrorDomain = @"kOTRXMPPErrorDomain";

NSTimeInterval const kOTRChatStatePausedTimeout   = 5;
NSTimeInterval const kOTRChatStateInactiveTimeout = 120;


@interface OTRXMPPManager()<XMPPvCardTempModuleDelegate>

@property (nonatomic, strong) OTRXMPPAccount *account;
@property (nonatomic) OTRProtocolConnectionStatus connectionStatus;

@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) XMPPJID *JID;
@property (nonatomic, strong) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, strong) OTRYapDatabaseRosterStorage * xmppRosterStorage;
@property (nonatomic, strong) OTRCertificatePinning * certificatePinningModule;
@property (nonatomic, readwrite) BOOL isXmppConnected;
@property (nonatomic, strong) NSMutableDictionary * buddyTimers;
@property (nonatomic) dispatch_queue_t workQueue;
@property (nonatomic) BOOL isRegisteringNewAccount;
@property (nonatomic, strong) OTRLocation *location;

@property (nonatomic, strong) historyManager * historyManager;



@property (nonatomic, strong) YapDatabaseConnection *databaseConnection;

@property (nonatomic, strong)  NSMutableDictionary * SJRoomsDic;

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;
- (void)failedToConnect:(NSError *)error;

@end


@implementation OTRXMPPManager

static int groupChatNotGoodAttempts_ = 0;


+(void)clearGroupChatNotGoodAttempts{
    groupChatNotGoodAttempts_ = 0;
}

- (id)init
{
    if (self = [super init]) {
        
        NSString * queueLabel = [NSString stringWithFormat:@"%@.work.%@",[self class],self];
        self.workQueue = dispatch_queue_create([queueLabel UTF8String], 0);
        self.connectionStatus = OTRProtocolConnectionStatusDisconnected;
        self.buddyTimers = [NSMutableDictionary dictionary];
        self.databaseConnection = [OTRDatabaseManager sharedInstance].readWriteDatabaseConnection;
        self.isRoomError = NO;
    }
    return self;
}

- (id) initWithAccount:(OTRAccount *)newAccount {
    if(self = [self init])
    {
        NSAssert([newAccount isKindOfClass:[OTRXMPPAccount class]], @"Must have XMPP account");
        self.isRegisteringNewAccount = NO;
        self.account = (OTRXMPPAccount *)newAccount;
        
        // Setup the XMPP stream
        [self setupStream];
        
        self.buddyTimers = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)dealloc
{
	[self teardownStream];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream
{
	NSAssert(_xmppStream == nil, @"Method setupStream invoked multiple times");
    
	if (self.account.accountType == OTRAccountTypeFacebook) {
        self.xmppStream = [[XMPPStream alloc] initWithFacebookAppId:FACEBOOK_APP_ID];
    } else {
        self.xmppStream = [[XMPPStream alloc] init];
    }
    
    //Used to fetch correct account from XMPPStream in delegate methods especailly
    self.xmppStream.tag = self.account.uniqueId;
    
    self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicyRequired;
    
    [self.certificatePinningModule activate:self.xmppStream];
    
    XMPPMessageDeliveryReceipts * deliveryReceiptsMoodule = [[XMPPMessageDeliveryReceipts alloc] init];
    deliveryReceiptsMoodule.autoSendMessageDeliveryReceipts = YES;
    deliveryReceiptsMoodule.autoSendMessageDeliveryRequests = YES;
    [deliveryReceiptsMoodule activate:self.xmppStream];
	
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		// 
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		self.xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	// 
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	self.xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	// 
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
    
    //DDLogInfo(@"Unique Identifier: %@",self.account.uniqueIdentifier);
	
    OTRYapDatabaseRosterStorage * rosterStorage = [[OTRYapDatabaseRosterStorage alloc] init];
	
	self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:rosterStorage];
	
	self.xmppRoster.autoFetchRoster = YES;
    self.xmppRoster.autoClearAllUsersAndResources = NO;
	self.xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
	
	// Setup vCard support
	// 
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
    OTRvCardYapDatabaseStorage * vCardStorage  = [[OTRvCardYapDatabaseStorage alloc] init];
	self.xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:vCardStorage];
	
	self.xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.xmppvCardTempModule];
	
	// Setup capabilities
	// 
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	// 
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	// 
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.
	
	self.xmppCapabilitiesStorage = [[XMPPCapabilitiesCoreDataStorage alloc] initWithInMemoryStore];
    self.xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:self.xmppCapabilitiesStorage];
    
    self.xmppCapabilities.autoFetchHashedCapabilities = YES;
    self.xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    
	// Activate xmpp modules
    
	[self.xmppReconnect         activate:self.xmppStream];
	[self.xmppRoster            activate:self.xmppStream];
	[self.xmppvCardTempModule   activate:self.xmppStream];
	[self.xmppvCardAvatarModule activate:self.xmppStream];
	[self.xmppCapabilities      activate:self.xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[self.xmppStream addDelegate:self delegateQueue:self.workQueue];
	[self.xmppRoster addDelegate:self delegateQueue:self.workQueue];
    [self.xmppCapabilities addDelegate:self delegateQueue:self.workQueue];
    
	// Optional:
	// 
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	// 
	// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
	// For example, if you supply a JID like 'user@quack.com/rsrc'
	// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
	// 
	// If you don't specify a hostPort, then the default (5222) will be used.
	
    //	[xmppStream setHostName:@"talk.google.com"];
    //	[xmppStream setHostPort:5222];	
}

- (void)teardownStream
{
    [_xmppStream removeDelegate:self];
    [_xmppRoster removeDelegate:self];
    [_xmppCapabilities removeDelegate:self];

    [_xmppReconnect         deactivate];
    [_xmppRoster            deactivate];
    [_xmppvCardTempModule   deactivate];
    [_xmppvCardAvatarModule deactivate];
    [_xmppCapabilities      deactivate];

    [_xmppStream disconnect];

    _xmppStream = nil;
    _xmppReconnect = nil;
    _xmppRoster = nil;
    _xmppRosterStorage = nil;
    _xmppvCardTempModule = nil;
    _xmppvCardAvatarModule = nil;
    _xmppCapabilities = nil;
    _xmppCapabilitiesStorage = nil;
    _certificatePinningModule = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
// 
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
// 
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
// 
// For more information on working with XML elements, see the Wiki article:
// http://code.google.com/p/xmppframework/wiki/WorkingWithElements

- (XMPPStream *)xmppStream
{
    if(!_xmppStream)
    {
        if (self.account.accountType == OTRAccountTypeFacebook) {
            _xmppStream = [[XMPPStream alloc] initWithFacebookAppId:FACEBOOK_APP_ID];
        }
        else{
            _xmppStream = [[XMPPStream alloc] init];
        }
        _xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicyRequired;
    }
    return _xmppStream;
}

- (void)goOnline
{
   
        
        self.connectionStatus = OTRProtocolConnectionStatusConnected;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kOTRProtocolLoginSuccess object:self];
        XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
        
        [[self xmppStream] sendElement:presence];
    
 
    
    
  
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    
	
	[[self xmppStream] sendElement:presence];
}

- (NSString *)accountDomainWithError:(id)error;
{
    return self.account.domain;
}

- (void)didRegisterNewAccount
{
    self.isRegisteringNewAccount = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:OTRXMPPRegisterSucceededNotificationName object:self];
}
- (void)failedToRegisterNewAccount:(NSError *)error
{
    if (error) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:OTRXMPPRegisterFailedNotificationName object:self userInfo:@{kOTRNotificationErrorKey:error}];
    }
    else {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:OTRXMPPRegisterFailedNotificationName object:self];
    }
}

- (void)refreshStreamJID:(NSString *)myJID withPassword:(NSString *)myPassword
{
    int r = arc4random() % 99999;
    
    NSString * resource = [NSString stringWithFormat:@"%@%d",kOTRXMPPResource,r];
    
    self.JID = [XMPPJID jidWithString:myJID resource:resource];
    
	[self.xmppStream setMyJID:self.JID];
    
    self.password = myPassword;
}

- (BOOL)authenticateWithStream:(XMPPStream *)stream {
    NSError * error = nil;
    BOOL status = YES;
    if ([stream supportsXFacebookPlatformAuthentication]) {
        status = [stream authenticateWithFacebookAccessToken:self.password error:&error];
    }
    else if ([stream supportsXOAuth2GoogleAuthentication] && self.account.accountType == OTRAccountTypeGoogleTalk) {
        status = [stream authenticateWithGoogleAccessToken:self.password error:&error];
    }
    else {
        status = [stream authenticateWithPassword:self.password error:&error];
    }
    return status;
}

///////////////////////////////
#pragma mark Capabilities Collected
////////////////////////////////////////////

- (NSArray *)myFeaturesForXMPPCapabilities:(XMPPCapabilities *)sender
{
    return @[@"http://jabber.org/protocol/chatstates"];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connectWithJID:(NSString*) myJID password:(NSString*)myPassword;
{
    self.password = myPassword;
    self.connectionStatus = OTRProtocolConnectionStatusConnecting;
    
    self.JID = [XMPPJID jidWithString:myJID resource:self.account.resource];
    
    if (![self.JID.domain isEqualToString:self.xmppStream.myJID.domain]) {
        [self.xmppStream disconnect];
    }
    
	[self.xmppStream setMyJID:self.JID];
    //DDLogInfo(@"myJID %@",myJID);
	if (![self.xmppStream isDisconnected]) {
        [self authenticateWithStream:self.xmppStream];
         self.connectionStatus = OTRProtocolConnectionStatusConnected; //zigzagcorp fix connection status
		return YES;
	}
    
	//
	// If you don't want to use the Settings view to set the JID, 
	// uncomment the section below to hard code a JID and password.
	//
	// Replace me with the proper JID and password:
	//	myJID = @"user@gmail.com/xmppframework";
	//	myPassword = @"";
    
	
    
    
    NSError * error = nil;
    NSString * domainString = [self accountDomainWithError:error];
    if (error) {
        [self failedToConnect:error];
        return NO;
    }
    if ([domainString length]) {
        [self.xmppStream setHostName:domainString];
    }
    
    [self.xmppStream setHostPort:self.account.port];
	
    
	error = nil;
	if (![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{
		[self failedToConnect:error];
        
		DDLogError(@"Error connecting: %@", error);
        
		return NO;
	}
    
	return YES;
}
- (void)leaveAllRooms{
    
    NSLog(@"IS OLD FUNCTION leaveAllRooms");
    
    /*
    for (NSString *key in self.SJRoomsDic ){
        
        XMPPRoom * room = [self.SJRoomsDic objectForKey:key];
        
        [room leaveRoom];
    */
}

- (void)disconnect
{
    //[self leaveAllRooms];
    [self goOffline];
    [self.xmppStream disconnect];
   // [self clearSJRoomsDic];
   // [self.xmppStream disconnect]; //zigzagcorp

    
    if([OTRSettingsManager boolForOTRSettingKey:kOTRSettingKeyDeleteOnDisconnect])
    {
        [self.databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [OTRMessage zigDeleteAllMessagesForAccountId:self.account.uniqueId transaction:transaction];
        }];
    }
}

- (void)registerNewAccountWithPassword:(NSString *)newPassword
{
    self.isRegisteringNewAccount = YES;
    if (self.xmppStream.isConnected) {
        [self.xmppStream disconnect];
    }
    
    [self connectWithJID:self.account.username password:newPassword];
}

- (void)registerNewAccountWithPassword:(NSString *)newPassword stream:(XMPPStream *)stream
{
    NSError * error = nil;
    if ([stream supportsInBandRegistration]) {
        [stream registerWithPassword:self.password error:&error];
        if(error)
        {
            [self failedToRegisterNewAccount:error];
        }
    }
    else{
        error = [NSError errorWithDomain:OTRXMPPErrorDomain code:OTRXMPPUnsupportedAction userInfo:nil];
        [self failedToRegisterNewAccount:error];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStreamDidChangeMyJID:(XMPPStream *)stream
{
    if (![[stream.myJID bare] isEqualToString:self.account.username] || ![[stream.myJID resource] isEqualToString:self.account.resource])
    {
        self.account.username = [stream.myJID bare];
        self.account.resource = [stream.myJID resource];
        [self.databaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [self.account saveWithTransaction:transaction];
        }];
    }
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket 
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    settings[GCDAsyncSocketSSLProtocolVersionMin] = @(kTLSProtocol1);
    settings[GCDAsyncSocketSSLCipherSuites] = [OTRUtilities cipherSuites];
    settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (self.isRegisteringNewAccount) {
        [self registerNewAccountWithPassword:self.password stream:sender];
    }
    else{
        [self authenticateWithStream:sender];
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    self.connectionStatus = OTRProtocolConnectionStatusConnected;
    [groupChatManager willJoinAllRooms];
    //[groupChatManager updateRoomsWithFriends];
   
	[self goOnline];

    
    //TEST BLOCK ZIGZAGCORP BEGIN
    /*
     NSArray *accounts = [OTRAccountsManager allAccountsAbleToAddBuddies];
    
    OTRAccount *account = [accounts firstObject];
    
    OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:account];
    
    [xmppManager createChatRoom:@"group"];
     */
  
    //groupChatManager * GCM = [[groupChatManager alloc] init];

   // [GCM getListsGroupChatWithUsername];
    

   
    //Нужен для приема сообщений в групповом чате
  
    
    dispatch_async(dispatch_get_main_queue(), ^{
          [self setTimerMUCArchive];
        self.location = [[OTRLocation alloc] init];
        [self.location start]; //Отправляю координаты на сервер
    });
    
  
        
//Нужен для истории
    
  if(!self.historyManager)  self.historyManager =  [[historyManager alloc] init];
    [self.historyManager getHistoryOptionFromServer];
  
    
    
     //TEST BLOCK ZIGZAGCORP END
    
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    self.connectionStatus = OTRProtocolConnectionStatusDisconnected;
    [self failedToConnect:[OTRXMPPError errorForXMLElement:error]];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    
    
    if([iq.fromStr isEqualToString:self.account.username] && self.account.username){
        
        
       NSString * type = [iq attributeStringValueForName:@"type"];
        NSString * iqId = [iq elementID];
        
        //Жду результата что обновилась моявизитка
        if(self.xmppvCardTempModule.lastGeneratedId && [iqId isEqualToString:self.xmppvCardTempModule.lastGeneratedId]){
            
            if([type isEqualToString:@"result"]){
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DID_UPDATE_VCARD_FROM_SERVER object:self];
              
            } else if([type isEqualToString:@"error"]){
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ERROR_UPDATE_VCARD_FROM_SERVER object:self];
                 
            }
            
            
            self.xmppvCardTempModule.lastGeneratedId=nil;
            
        }
        
        
      //  <iq xmlns="jabber:client" from="test@safejab.com" to="test@safejab.com/safejab1699" id="A0C50063-79DF-45FA-918C-80CE8C020B8F" type="result"/>
        
        
       NSXMLElement * vCard = [iq elementForName:@"vCard" xmlns:@"vcard-temp"];
        
        if(vCard){
            
            self.myVCard =  [[ZIGMyVCard alloc] initWithVCard:vCard];
            
            //Просто говорю о том что получил vCard
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_I_GET_MY_VCARD object:self];
        
        }
        
       
        
      
      //  NSString * test = [delay stringValue];
        
     
        
       // if (delay)
      ///  {
       ///     NSString *stampValue = [delay attributeStringValueForName:@"stamp"];
    }
    
  

    
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [iq elementID]);
	return NO;
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    [self didRegisterNewAccount];
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)xmlError {
    
    self.isRegisteringNewAccount = NO;
    NSError * error = [OTRXMPPError errorForXMLElement:xmlError];
    [self failedToRegisterNewAccount:error];
}

-(OTRXMPPBuddy *)buddyWithMessage:(XMPPMessage *)message transaction:(YapDatabaseReadTransaction *)transaction
{
    OTRXMPPBuddy *buddy = [OTRXMPPBuddy fetchBuddyWithUsername:[[message from] bare] withAccountUniqueId:self.account.uniqueId transaction:transaction];
    return buddy;
}

-(void)receiveByeRoom:(XMPPMessage *)xmppMessage {
    
    NSString *subject = [[xmppMessage elementForName:@"subject"] stringValue];
    
    if([subject isEqualToString:@"bye"]) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"userLeaveRoom" object:self];
        [groupChatManager updateRoomsWithFriends];
        
        
        
        
   
    }
    
    
}



-(BOOL)isReceiveInvite:(XMPPMessage *)xmppMessage {
    
    //Только при принятии сообщения
    
  // NSString *elementID = [xmppMessage elementID];
    
     NSString *subject = [[xmppMessage elementForName:@"subject"] stringValue];
    
    if([subject isEqualToString:@"invite"]) {
        
          NSString *roomId = [[xmppMessage elementForName:@"body"] stringValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
        groupChatManager * GCM = [[groupChatManager alloc] init];
        
        [GCM getListsGroupChatWithUsername:update];
        
        GCM.linkToGroupChatManager = self;
        GCM.roomIDForLink = roomId;
        });
    
        
        return YES;
    } else {
        return NO;
    }
    
    
    
    
}


- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)xmppMessage
{
    
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    
    if([self isReceiveGroupMessageReadAll:xmppMessage]) return ; //Если приняли уведомление то нах оно
    if([self isReceiveInvite:xmppMessage]) return ; //Если это просто приглашение нах оно нам в базе )
   if([self isReciveIOpenSecurMessage:xmppMessage]) return ; //Если это сообщение о прочтении секурного сообщения то нах оно нам в базе
    

    
    XMPPJID *from = [xmppMessage from];
   __block BOOL isGroupChat = SafeJabTypeIsEqual(from.domain, MUC_JABBER_HOST);
   __block BOOL isGroupChatCurAccOutgoing;
    __block BOOL isSecurBody = [self isSecurBody:xmppMessage];

    
  //  DDLogInfo(@"didReceiveMessage %@", [from resource] );
    
  
    
    [self.databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
    
        
  
        
         //XMPPJID *to = [xmppMessage to];
        
        if(isGroupChat && [from.resource isEqualToString:self.account.username]){
            isGroupChatCurAccOutgoing = YES;
        } else {
             isGroupChatCurAccOutgoing = NO;
        }
        
     //   BOOL isDB = [OTRMessage isMessageInDBForMessageId:[xmppMessage elementID] transaction:transaction];
        
        if([xmppMessage hasReceiptResponse] && ![xmppMessage isErrorMessage]){
            [OTRMessage receivedDeliveryReceiptForMessageId:[xmppMessage receiptResponseID] transaction:transaction];
            
            //Остановить если это просто отчет о доставке
            return ;
        }
      
     /*
        if(isGroupChatCurAccOutgoing){
         //Если групповой чат то рассматривать входящие сообщения как отчет о доставке (ну если конечно сообщение с тем же id)
            
            BOOL isDB = [OTRMessage isMessageInDBForMessageId:[xmppMessage elementID] transaction:transaction];
            
            if(isDB) {
            //Отметить сообщение о доставке
            [OTRMessage receivedDeliveryReceiptForMessageId:[xmppMessage elementID] transaction:transaction];
                
                
                //Ну а такие сообщения мы не сохраняем в базе )))
            return ;
                
            }
        } else if(SafeJabTypeIsEqual(from.domain, MUC_JABBER_HOST)){
             BOOL isDB = [OTRMessage isMessageInDBForMessageId:[xmppMessage elementID] transaction:transaction];
            //Если заходим в комнату по второму разу проигноривоть сообщения в комнате
            if(isDB) return;
        
        }
      */
        
        [self receiveByeRoom:xmppMessage];
        [self receiveRenameRoom:xmppMessage];
        [self receiveImAddFriend:xmppMessage];

        
        OTRXMPPBuddy *messageBuddy = [self buddyWithMessage:xmppMessage transaction:transaction];
        if ([xmppMessage isErrorMessage]) {
            NSError *error = [xmppMessage errorMessage];
            DDLogCWarn(@"XMPP Error: %@",error);
        }
        else if([xmppMessage hasChatState])
        {
            if([xmppMessage hasComposingChatState]){
                messageBuddy.chatState = kOTRChatStateComposing;
                
            } else if([xmppMessage hasPausedChatState])
                 messageBuddy.chatState = kOTRChatStatePaused;
            else if([xmppMessage hasActiveChatState])
                 messageBuddy.chatState = kOTRChatStateActive;
            else if([xmppMessage hasInactiveChatState])
                 messageBuddy.chatState = kOTRChatStateInactive;
            else if([xmppMessage hasGoneChatState])
                 messageBuddy.chatState = kOTRChatStateGone;
            [messageBuddy saveWithTransaction:transaction];
        }
        


       
        //[xmppMessage elementID];
        
       // [xmppMessage from];
        
     //   if(SafeJabTypeIsEqual(messageBuddy.username, MUC_JABBER_HOST) &&){
      //      [OTRMessage receivedDeliveryReceiptForMessageId:[xmppMessage elementID] transaction:transaction];
       // }
        
   
    
    /*
        if ([xmppMessage hasReceiptResponse] && ![xmppMessage isErrorMessage]) {
            [OTRMessage receivedDeliveryReceiptForMessageId:[xmppMessage receiptResponseID] transaction:transaction];
        }
      */
        
        if ([xmppMessage isMessageWithBody] && ![xmppMessage isErrorMessage])
        {
            NSString *body = [[xmppMessage elementForName:@"body"] stringValue];
            
            NSDate * date = [xmppMessage delayedDeliveryDate];
            
            OTRMessage *message = [[OTRMessage alloc] init];
            
            if(isGroupChatCurAccOutgoing){
                  message.incoming = NO;
            } else {
                  message.incoming = YES;
            }
            
            if(isGroupChat){
                message.groupChatUserJid = from.resource; //Сохраняем от кого пришло сообщение в групповом чате (жид@домен.рф)
            }
            
            if(isSecurBody){
                message.securBody = [[xmppMessage elementForName:@"securBody"] stringValue];
                message.lifeTime = [[xmppMessage elementForName:@"lifeTime"] stringValue];
            }
         
            message.text = body;
            message.buddyUniqueId = messageBuddy.uniqueId;
            if (date) {
                message.date = date;
            } else {
                message.isSorted = YES;
            }
            
            message.messageId = [xmppMessage elementID];
            
            
            [[OTRKit sharedInstance] decodeMessage:message.text username:messageBuddy.username accountName:self.account.username protocol:kOTRProtocolTypeXMPP tag:message];
            
        }
        
        if (messageBuddy) {
            
            [transaction setObject:messageBuddy forKey:messageBuddy.uniqueId inCollection:[OTRXMPPBuddy collection]];
        }
    }];
}
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
 
    
   //    NSXMLElement *x = [presence elementForName:@"x" xmlns:XMLMS_PROTOCOL_MUC_USER];
    
  //    BOOL isDestroy     = [x elementForName:@"destroy"] != nil;
    
    
    
  //  NSString * domain = [[presence from] domain];
 //   BOOL isGroupChat = SafeJabTypeIsEqual(domain,  MUC_JABBER_HOST);
   // NSString* type =[presence type];
    
  //  if([type isEqualToString:@"unavailable"] && isGroupChat){
 //       return ; //Ели мы узнаем о удаление или о выходе из группового чата игнорируем
 //   }
    
    /*
    [self.databaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {

        OTRBuddy *buddy = [OTRBuddy fetchBuddyForUsername:username accountName:accountName transaction:transaction];

        
    } completionBlock:^{
        [[OTRProtocolManager sharedInstance] sendMessage:message];
    }];
    */
  //  if(isDestroy){
  //      [self deleteRoomFromDBWithPresence:presence];
  //  }
    
    //  NSLog(@"zigPresence c %hhd", isDestroy);
    
 //Принимаю уведомление и обновляю список комнат
    [self receiveUpdateRoomPresence:presence];
    

    
    
	DDLogVerbose(@"%@: %@ - %@\nType: %@\nShow: %@\nStatus: %@", THIS_FILE, THIS_METHOD, [presence from], [presence type], [presence show],[presence status]);
}

-(void)deleteRoomFromDBWithPresence:(XMPPPresence *)presence{
    
    NSString * domain = [[presence from] domain];
    BOOL isGroupChat = SafeJabTypeIsEqual(domain,  MUC_JABBER_HOST);
    
    
    if(isGroupChat){
        NSString * username = [[presence from] bare];
        OTRAccount *acc = SJAccount();
        
        
        
        
        __block OTRBuddy *buddy = nil;
        [[OTRDatabaseManager sharedInstance].mainThreadReadOnlyDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
             buddy = [OTRBuddy fetchBuddyWithUsername:username withAccountUniqueId:acc.uniqueId transaction:transaction];
        }];
        
        if(!buddy) return; //Если мы администратор то нам уже не надо удалять
        
      [[[OTRProtocolManager sharedInstance] protocolForAccount:acc] removeBuddies:@[buddy]];
      
        
         dispatch_async(dispatch_get_main_queue(), ^{
             
             groupChatManager * GCM = [[groupChatManager alloc] init];
             [GCM getListsGroupChatWithUsername:update];
         });
    }
    
    
    
}


- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    if ([message.elementID length]) {
        [self.databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [OTRMessage enumerateMessagesWithMessageId:message.elementID transaction:transaction usingBlock:^(OTRMessage *message, BOOL *stop) {
                message.error = error;
                [message saveWithTransaction:transaction];
                *stop = YES;
            }];
        }];
    }
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(XMPPPresence *)presence error:(NSError *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}


-(void)checkGroupChatError:(NSError *)error{
   
    NSLog(@"OLD FUNCTION checkGroupChatError");
    /*
    groupChatNotGoodAttempts_++;
    
    if(groupChatNotGoodAttempts_ <= 3) return ;
    
  NSString * strGroupChatErr = @"Socket closed by remote peer";
    
    if([strGroupChatErr isEqualToString:[error localizedDescription]]){
        
       if(groupChatNotGoodAttempts_ <= 3) return ; // Если количество не удачных попыток меньше трех не отключать групповой чат
        
        
        DDLogInfo(@"ErrZUZUkGroupChatError");

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DID_ERROR_GROUP_CHAT object:self];
        self.isRoomError = YES;
    }
    */
}



- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
   
    

	DDLogVerbose(@"ZUZU %@: %@ %@", THIS_FILE, THIS_METHOD, error);
    
   // [self checkGroupChatError:error]; отключил пока проверку на ошибку
    
    self.connectionStatus = OTRProtocolConnectionStatusDisconnected;
	
	if (!self.isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
        [self failedToConnect:error];
	}
    else {
        [self.databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            NSArray *allBuddies = [self.account allBuddiesWithTransaction:transaction];
            [allBuddies enumerateObjectsUsingBlock:^(OTRXMPPBuddy *buddy, NSUInteger idx, BOOL *stop) {
                buddy.status = OTRBuddyStatusOffline;
                buddy.statusMessage = nil;
                [transaction setObject:buddy forKey:buddy.uniqueId inCollection:[OTRXMPPBuddy collection]];
            }];
            
        }];
    }
    self.isXmppConnected = NO;
    [self clearTimerMUCArchive];
    clearSJAccount(); //На всякий
     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_XMPP_STREAM_DID_DISCONNECT object:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
  

    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
	NSString *jidStrBare = [presence fromStr];
    
    [self.databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        OTRXMPPPresenceSubscriptionRequest *request = [OTRXMPPPresenceSubscriptionRequest fetchPresenceSubscriptionRequestWithJID:jidStrBare accontUniqueId:self.account.uniqueId transaction:transaction];
        if (!request) {
            request = [[OTRXMPPPresenceSubscriptionRequest alloc] init];
        }
        
        request.jid = jidStrBare;
        request.accountUniqueId = self.account.uniqueId;
        
        [request saveWithTransaction:transaction];
    }];
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    //verry unclear what this delegate call is supposed to do with jabber.ccc.de it seems to have all the subscription=both,none and jid
    /*
    if ([iq isSetIQ] && [[[[[[iq elementsForName:@"query"] firstObject] elementsForName:@"item"] firstObject] attributeStringValueForName:@"subscription"] isEqualToString:@"from"]) {
        NSString *jidString = [[[[[iq elementsForName:@"query"] firstObject] elementsForName:@"item"] firstObject] attributeStringValueForName:@"jid"];
        
        [self.databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            OTRXMPPPresenceSubscriptionRequest *request = [OTRXMPPPresenceSubscriptionRequest fetchPresenceSubscriptionRequestWithJID:jidString accontUniqueId:self.account.uniqueId transaction:transaction];
            if (!request) {
                request = [[OTRXMPPPresenceSubscriptionRequest alloc] init];
            }
            
            request.jid = jidString;
            request.accountUniqueId = self.account.uniqueId;
            
            [transaction setObject:request forKey:request.uniqueId inCollection:[OTRXMPPPresenceSubscriptionRequest collection]];
        }];
    }
    else if ([iq isSetIQ] && [[[[[[iq elementsForName:@"query"] firstObject] elementsForName:@"item"] firstObject] attributeStringValueForName:@"subscription"] isEqualToString:@"none"])
    {
        [self.databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            NSString *jidString = [[[[[iq elementsForName:@"query"] firstObject] elementsForName:@"item"] firstObject] attributeStringValueForName:@"jid"];
            
            OTRXMPPBuddy *buddy = [[OTRXMPPBuddy fetchBuddyWithUsername:jidString withAccountUniqueId:self.account.uniqueId transaction:transaction] copy];
            buddy.pendingApproval = YES;
            [buddy saveWithTransaction:transaction];
        }];
    }
    
    */
    
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark OTRProtocol 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-(void)receiveImAddFriend:(XMPPMessage *)xmppMessage {
    
    NSString *subject = [[xmppMessage elementForName:@"subject"] stringValue];
    
    if([subject isEqualToString:@"addFriend"]) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"userLeaveRoom" object:self];
        dispatch_async(dispatch_get_main_queue(), ^{
            //Вот тут я наконец присоединяю комнаты к чату
            groupChatManager * GCM = [[groupChatManager alloc] init];
            [GCM getListsGroupChatWithUsername:update];
        });
        
        
    }
    
    
}


-(void)receiveRenameRoom:(XMPPMessage *)xmppMessage {
    
    NSString *subject = [[xmppMessage elementForName:@"subject"] stringValue];
    
    if([subject isEqualToString:@"renameRoom"]) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_ROOM_LIST object:self];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //Вот тут я наконец присоединяю комнаты к чату
            groupChatManager * GCM = [[groupChatManager alloc] init];  
            [GCM getListsGroupChatWithUsername:update];
        });
        
    }
    
    
}


- (void) sendMessage:(OTRMessage*)message
{
    
   
    
//zigzagcorp info
    NSString *text = message.text;
  
    BOOL isOTRMes;
    
    //Отключаю пересылку невимыми сообщениями zigzagcorp if (Нахуй ваще отрубил но условие навсякий оставил)
    if([text length] > 4){
        NSLog(@"isOTR");
    isOTRMes= [[text substringToIndex:4] isEqualToString:@"?OTR"];
    } else {
        isOTRMes=NO;
    }
    
if(!isOTRMes)
{
    
    
    
    __block OTRBuddy *buddy = nil;
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        buddy = [message buddyWithTransaction:transaction];
    }];
    
    [self invalidatePausedChatStateTimerForBuddyUniqueId:buddy.uniqueId];
    
    if ([text length])
    {
        NSString * messageID = message.messageId;
        NSString * roomID;
         //При отправке сообщения нас интересует тип сообщения (Групповое или Личное)
        NSString * messageType = @"";
        if(SafeJabTypeIsEqual(buddy.username, MUC_JABBER_HOST)){
            
              roomID =  [ [XMPPJID jidWithString:buddy.username] user];
            
           // [self sendPushForRoomFrom:self.account.username roomID:roomID body:message.text];
            
            messageType = @"groupchat";
           
        } else {
            messageType = @"chat";
        }
        
   
        
        
        XMPPMessage * xmppMessage = [XMPPMessage messageWithType:messageType to:[XMPPJID jidWithString:buddy.username] elementID:messageID];
        [xmppMessage addBody:text];

        [xmppMessage addActiveChatState];
        
    
    
        
        
        if([messageType isEqualToString:@"groupchat"]){
            
            NSString *from = [NSString stringWithFormat:@"%@/%@", buddy.username, self.account.username];
            [xmppMessage addAttributeWithName:@"from" stringValue:from];
            
            
            NSXMLElement *delay = [NSXMLElement elementWithName:@"delay" stringValue:@"placeToInsertDelay"];
          /*
            [delay addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:delay"];
            [delay addAttributeWithName:@"from" stringValue:MUC_JABBER_HOST];
            [delay addAttributeWithName:@"stamp" stringValue:[MUCArhive timeStamp]];
             */
             [xmppMessage addChild:delay];
         
            
        [MUCArhive saveRoomMessage:roomID message:(XMPPMessage *)xmppMessage from:self.account.username]; //Zig test
            
        
       
        } else {
            [self.xmppStream sendElement:xmppMessage];
        }
        
		
    }
}
}

- (NSString*) accountName
{
  
    
    return [self.JID full];
    
}

- (NSString*) type {
    return kOTRProtocolTypeXMPP;
}

-(void)connectWithPassword:(NSString *)myPassword
{

         [self connectWithJID:self.account.username password:myPassword];
 
   
}

-(void)sendChatState:(OTRChatState)chatState withBuddyID:(NSString *)buddyUniqueId
{
    
    
    dispatch_async(self.workQueue, ^{
        
        __block OTRXMPPBuddy *buddy = nil;
        [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            buddy = [OTRXMPPBuddy fetchObjectWithUniqueID:buddyUniqueId transaction:transaction];
        }];
        
        if (buddy.lastSentChatState == chatState) {
            return;
        }
        
        XMPPMessage * xMessage = [[XMPPMessage alloc] initWithType:@"chat" to:[XMPPJID jidWithString:buddy.username]];
        BOOL shouldSend = YES;
        
        if (chatState == kOTRChatStateActive) {
            //Timers
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self pausedChatStateTimerForBuddyObjectID:buddyUniqueId] invalidate];
                [self restartInactiveChatStateTimerForBuddyObjectID:buddyUniqueId];
            });
            
            [xMessage addActiveChatState];
        }
        else if (chatState == kOTRChatStateComposing)
        {
              shouldSend = NO;
            
            /*
             Запрещаю показывать статус печатаю (надо будет исправить zigzagpoint)
             
            if(buddy.lastSentChatState !=kOTRChatStateComposing)
                [xMessage addComposingChatState];
            else
                shouldSend = NO;
            
            //Timers
            dispatch_async(dispatch_get_main_queue(), ^{
                [self restartPausedChatStateTimerForBuddyObjectID:buddy.uniqueId];
                [[self inactiveChatStateTimerForBuddyObjectID:buddy.uniqueId] invalidate];
            });
             */
        }
        else if(chatState == kOTRChatStateInactive)
        {
            if(buddy.lastSentChatState != kOTRChatStateInactive)
                [xMessage addInactiveChatState];
            else
                shouldSend = NO;
        }
        else if (chatState == kOTRChatStatePaused)
        {
            [xMessage addPausedChatState];
        }
        else if (chatState == kOTRChatStateGone)
        {
            [xMessage addGoneChatState];
        }
        else
        {
            shouldSend = NO;
        }
        
        if(shouldSend)
        {
            [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                OTRXMPPBuddy *localBuddy = [OTRXMPPBuddy fetchObjectWithUniqueID:buddy.uniqueId transaction:transaction];
                localBuddy.lastSentChatState = chatState;
                
                [localBuddy saveWithTransaction:transaction];
            }];
            [self.xmppStream sendElement:xMessage];
        }
    });
}

- (void) addBuddy:(OTRXMPPBuddy *)newBuddy
{
    XMPPJID * newJID = [XMPPJID jidWithString:newBuddy.username];
    [self.xmppRoster addUser:newJID withNickname:newBuddy.displayName];
}
- (void) setDisplayName:(NSString *) newDisplayName forBuddy:(OTRXMPPBuddy *)buddy
{
    XMPPJID * jid = [XMPPJID jidWithString:buddy.username];
    [self.xmppRoster setNickname:newDisplayName forUser:jid];
    
}
-(void)removeBuddies:(NSArray *)buddies
{
    for (OTRXMPPBuddy *buddy in buddies){
        XMPPJID * jid = [XMPPJID jidWithString:buddy.username];
        [self.xmppRoster removeUser:jid]; //zigzagcorp point
    }
    
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeObjectsForKeys:[buddies valueForKey:NSStringFromSelector(@selector(uniqueId))] inCollection:[OTRXMPPBuddy collection]];
    }];



}
-(void)blockBuddies:(NSArray *)buddies
{
    for (OTRXMPPBuddy *buddy in buddies){
        XMPPJID * jid = [XMPPJID jidWithString:buddy.username];
        [self.xmppRoster revokePresencePermissionFromUser:jid];
    }
}

//Chat State

-(OTRXMPPBudyTimers *)buddyTimersForBuddyObjectID:(NSString *)
managedBuddyObjectID
{
    OTRXMPPBudyTimers * timers = (OTRXMPPBudyTimers *)[self.buddyTimers objectForKey:managedBuddyObjectID];
    return timers;
}

-(NSTimer *)inactiveChatStateTimerForBuddyObjectID:(NSString *)
managedBuddyObjectID
{
   return [self buddyTimersForBuddyObjectID:managedBuddyObjectID].inactiveChatStateTimer;
    
}
-(NSTimer *)pausedChatStateTimerForBuddyObjectID:(NSString *)
managedBuddyObjectID
{
    return [self buddyTimersForBuddyObjectID:managedBuddyObjectID].pausedChatStateTimer;
}

-(void)restartPausedChatStateTimerForBuddyObjectID:(NSString *)managedBuddyObjectID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        OTRXMPPBudyTimers * timer = (OTRXMPPBudyTimers *)[self.buddyTimers objectForKey:managedBuddyObjectID];
        if(!timer)
        {
            timer = [[OTRXMPPBudyTimers alloc] init];
        }
        [timer.pausedChatStateTimer invalidate];
        timer.pausedChatStateTimer = [NSTimer scheduledTimerWithTimeInterval:kOTRChatStatePausedTimeout target:self selector:@selector(sendPausedChatState:) userInfo:managedBuddyObjectID repeats:NO];
        [self.buddyTimers setObject:timer forKey:managedBuddyObjectID];
    });
    
}
-(void)restartInactiveChatStateTimerForBuddyObjectID:(NSString *)managedBuddyObjectID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        OTRXMPPBudyTimers * timer = (OTRXMPPBudyTimers *)[self.buddyTimers objectForKey:managedBuddyObjectID];
        if(!timer)
        {
            timer = [[OTRXMPPBudyTimers alloc] init];
        }
        [timer.inactiveChatStateTimer invalidate];
        timer.inactiveChatStateTimer = [NSTimer scheduledTimerWithTimeInterval:kOTRChatStateInactiveTimeout target:self selector:@selector(sendInactiveChatState:) userInfo:managedBuddyObjectID repeats:NO];
        [self.buddyTimers setObject:timer forKey:managedBuddyObjectID];
    });
}
-(void)sendPausedChatState:(NSTimer *)timer
{
    NSString * managedBuddyObjectID= (NSString *)timer.userInfo;
    dispatch_async(dispatch_get_main_queue(), ^{
        [timer invalidate];
    });
    [self sendChatState:kOTRChatStatePaused withBuddyID:managedBuddyObjectID];
}
-(void)sendInactiveChatState:(NSTimer *)timer
{
    NSString *managedBuddyObjectID= (NSString *)timer.userInfo;
    dispatch_async(dispatch_get_main_queue(), ^{
        [timer invalidate];
    });
    
    [self sendChatState:kOTRChatStateInactive withBuddyID:managedBuddyObjectID];
}

- (void)invalidatePausedChatStateTimerForBuddyUniqueId:(NSString *)buddyUniqueId
{
    [[self pausedChatStateTimerForBuddyObjectID:buddyUniqueId] invalidate];
}

- (void)failedToConnect:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:kOTRProtocolLoginFail object:self userInfo:@{kOTRNotificationErrorKey:error}];
        }
        else {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:kOTRProtocolLoginFail object:self];
        }
    });
}

- (OTRCertificatePinning *)certificatePinningModule
{
    if(!_certificatePinningModule){
        _certificatePinningModule = [OTRCertificatePinning defaultCertificates];
        _certificatePinningModule.delegate = self;
    }
    return _certificatePinningModule;
}

- (void)newTrust:(SecTrustRef)trust withHostName:(NSString *)hostname systemTrustResult:(SecTrustResultType)trustResultType
{
    NSData * certifcateData = [OTRCertificatePinning dataForCertificate:[OTRCertificatePinning certForTrust:trust]];
    DDLogVerbose(@"New trustResultType: %d certLength: %d", (int)trustResultType, (int)certifcateData.length);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self failedToConnect:[OTRXMPPError errorForTrustResult:trustResultType withCertData:certifcateData hostname:hostname]];
    });
}

//Групповой чат


- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    
  /*
    
    [self setSJRooms:sender];
    
    
    if(self.arrFriendsInGroup){
        
        NSString * roomID =  [sender roomJID].user;
        
        groupChatManager *GCM = [[groupChatManager alloc] init];
        
        
     [GCM createListOfFriendsForChatRoom:self.arrFriendsInGroup roomID:roomID];
        
        
        
        for(NSString *buddyUsername in self.arrFriendsInGroup){
            
            [self sendInvite:buddyUsername roomID: roomID];
            
            
            
        }
       
        dispatch_async(dispatch_get_main_queue(), ^{
            //Вот тут я наконец присоединяю комнаты к чату
            groupChatManager * GCM = [[groupChatManager alloc] init];
        
            GCM.roomsWithFriends = [groupChatManager sharedRoomsWithFriends];
            
            [GCM joinAllRooms];
            
            
            [self.linkToOTRComposeViewController goChatWithNewRoom:roomID];
        });
        
        
 
        

    }
    
    self.arrFriendsInGroup = nil;
    */
 
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    
    
  //  [self setSJRooms:sender];
    
  //  [sender inviteUser:[XMPPJID jidWithString:@"zduck@safejab.com/safejab27107"] withMessage:@"Greetings!"];
   // [sender inviteUser:[XMPPJID jidWithString:@"zduck"] withMessage:@"Greetings!"];
  //  [sender configureRoomUsingOptions:nil];
 //    [sender fetchConfigurationForm];
    /*
    [sender inviteUser:[XMPPJID jidWithString:@"abc@safejab.com"] withMessage:@"Greetings!"];
    [sender inviteUser:[XMPPJID jidWithString:@"test@safejab.com"] withMessage:@"Greetings!"];
    [sender inviteUser:[XMPPJID jidWithString:@"p.s@safejab.com"] withMessage:@"Greetings!"];
        */
 //   [sender inviteUser:[XMPPJID jidWithString:@"zduck@safejab.com"] withMessage:@"HiZig"];
 
    DDLogInfo(@"xmppRoomDidJoinZIG%@: %@", THIS_FILE, THIS_METHOD);
  //  if( [self getSJRooms:@"931c5d2b-737c-4761-b832-98bd002fe93e"].isJoined ){
   //     NSLog(@"CisJoinedYES");
  //  } else  NSLog(@"CisJoinedNO");
}

-(void)xmppRoomDidLeave:(XMPPRoom *)sender{
  //  if( [self getSJRooms:@"931c5d2b-737c-4761-b832-98bd002fe93e"].isJoined ){
  //      NSLog(@"isJoinedYES");
  //  } else  NSLog(@"isJoinedNO");
    
   // [self deleteSJRoomFromDic:sender];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm{
    
    DDLogInfo(@"didFetchConfigurationForm");
    NSXMLElement *newConfig = [configForm copy];
    NSArray *fields = [newConfig elementsForName:@"field"];
    for (NSXMLElement *field in fields) {
        NSString *var = [field attributeStringValueForName:@"var"];
        // Make Room Persistent
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
    }
    [sender configureRoomUsingOptions:newConfig];
}


-(void)joinRoomById:(NSString *) roomID{
    
   
    
       // XMPPJID *room= [XMPPJID jidWithString:fullRoomID];
    
   // OTRBuddy * room = [[OTRBuddy alloc] init];
   // room.username = [NSString stringWithFormat:@"%@@%@", roomID, MUC_JABBER_HOST];
    
   NSString* newBuddyAccountName = [NSString stringWithFormat:@"%@@%@", roomID, MUC_JABBER_HOST];
    
    __block OTRXMPPBuddy *buddy = nil;
    __block BOOL needSave = NO;
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        buddy = [OTRXMPPBuddy fetchBuddyWithUsername:newBuddyAccountName withAccountUniqueId:self.account.uniqueId transaction:transaction];
        if (!buddy) {
            
            buddy = [[OTRXMPPBuddy alloc] init];
            buddy.username = newBuddyAccountName;
            buddy.accountUniqueId = self.account.uniqueId;
            buddy.displayName = nil;
            [buddy saveWithTransaction:transaction];
            needSave = YES;
        }
        
       
    }];
    
   // id<OTRProtocol> protocol = [[OTRProtocolManager sharedInstance] protocolForAccount:self.account];
   // [protocol addBuddy:buddy];
    
    if(!needSave){
    
        [self.databaseConnection readWriteWithBlock:^(YapDatabaseReadTransaction *transaction) {
            if(![OTRBuddy fetchBuddyWithUsername:buddy.username withAccountUniqueId:self.account.uniqueId transaction:transaction]){
                
               // id<OTRProtocol> protocol = [[OTRProtocolManager sharedInstance] protocolForAccount:self.account];
                [self addBuddy:buddy];
                
              //  [self addBuddy:room];
                
            }
        }];
    }
  
    

    
    
}



- (void)createChatRoom:(NSString *) newRoomName
{
    
   // if([self getSJRooms:newRoomName].isJoined) {
        //DDLogInfo(@"YESisJoinedRoom");
        //Если комната существует то не коннектимся по второму разу
   //     return;
  //  } else if(self.isRoomError){
        
    //    return; //Если мы поймали ошибку реконекта то проигнорировать
   // }
    
    
    /*
    
    NSString *ninckName = self.account.username;
    
    DDLogInfo(@"createChatRoom: %@-%@", newRoomName, ninckName);
    
    XMPPRoomMemoryStorage * _roomMemory = [[XMPPRoomMemoryStorage alloc]init];
    NSString* roomID = [NSString stringWithFormat:@"%@@%@", newRoomName, MUC_JABBER_HOST];
    XMPPJID * roomJID = [XMPPJID jidWithString:roomID];
    XMPPRoom* xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_roomMemory
                                                           jid:roomJID
                                                 dispatchQueue:dispatch_get_main_queue()];
    
   // NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
   // [history addAttributeWithName:@"maxstanzas" stringValue:@"50"];
    
    [xmppRoom activate:self.xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoom joinRoomUsingNickname:ninckName
                            history:nil
                           password:@"secret"];
    
    */
    
    DDLogInfo(@"createChatRoom: %@", newRoomName);
    
  

    [self joinRoomById:newRoomName];
    
    
    if(self.arrFriendsInGroup){
        
        NSString * roomID =  newRoomName;
        
        groupChatManager *GCM = [[groupChatManager alloc] init];
        
        
        [GCM createListOfFriendsForChatRoom:self.arrFriendsInGroup roomID:roomID];
        
        
        
    //    for(NSString *buddyUsername in self.arrFriendsInGroup){
      //      [self sendInvite:buddyUsername roomID: roomID];
            
      //  }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //Вот тут я наконец присоединяю комнаты к чату
           // groupChatManager * GCM = [[groupChatManager alloc] init];
            
          //  GCM.roomsWithFriends = [groupChatManager sharedRoomsWithFriends];
            
         //   [GCM joinAllRooms];
            
            
            [self.linkToOTRComposeViewController goChatWithNewRoom:roomID];
        });
        
        
        
        
        
    }
    
    self.arrFriendsInGroup = nil;
   
    
            //[xmppRoom inviteUser:[XMPPJID jidWithString:@"zduck@safejab.com"] withMessage:@"Come Join me"];
    /*
     NSString * xmppRoomJID = [NSString stringWithFormat:@"%@@%@", newRoomName, MUC_JABBER_HOST];
     XMPPJID *roomJID = [XMPPJID jidWithString:xmppRoomJID];
     
     XMPPRoomMemoryStorage *roomMemoryStorage = [[XMPPRoomMemoryStorage alloc] init];
     
     XMPPRoom * xmppRoom = [[XMPPRoom alloc]
     initWithRoomStorage:roomMemoryStorage
     jid:roomJID
     dispatchQueue:dispatch_get_main_queue()];
     
     [xmppRoom activate:[self xmppStream]];
     [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
     [xmppRoom joinRoomUsingNickname:ninckName history:nil];
     [xmppRoom fetchConfigurationForm];
     */

}

-(void)setSJRooms:(XMPPRoom *)room{
    
    NSLog(@"IS OLD FUNCTION setSJRooms");
/*
    if(!self.SJRoomsDic){
        self.SJRoomsDic = [[NSMutableDictionary alloc] init];
    }

    [self.SJRoomsDic setObject:room forKey:[room roomJID].user]; //[room roomJID].user это RoomId
 */
   
}

-(void)deleteSJRoomFromDic:(XMPPRoom *)room{
    NSLog(@"IS OLD FUNCTION deleteSJRoomFromDic");
    /*
    if(self.SJRoomsDic && room){
        [self.SJRoomsDic removeObjectForKey:[room roomJID].user];
    }
     */
}

-(void)clearSJRoomsDic{
    NSLog(@"IS OLD FUNCTION clearSJRoomsDic");
    /*
    self.SJRoomsDic = nil;
     */
}

-(XMPPRoom *)getSJRooms:(NSString *)roomID{
   
    NSLog(@"IS OLD FUNCTION getSJRooms");
    /*
    
    if(!self.SJRoomsDic) return nil;
    
    return [self.SJRoomsDic valueForKey:roomID];
     */
    return nil;
}


-(void)deleteXmppRoom: (XMPPRoom *)room {
    NSLog(@"IS OLD FUNCTION deleteXmppRoom");
    /*
    [self deleteSJRoomFromDic:room];
    [room destroyRoom];
     */
}




- (void)xmppRoomDidDestroy:(XMPPRoom *)sender {
    //Не срабатывает но комната удаляется
    NSLog(@"xmppRoomDidDestroy");
}

#pragma mark - Секурные сообщения

- (void)sendTimeMessage:(OTRMessage*)message timeOption:(NSString *)option{
    NSString *text = message.text;
    
    BOOL isOTRMes;
    
    //Отключаю пересылку невимыми сообщениями zigzagcorp if (Нахуй ваще отрубил но условие навсякий оставил)
    if([text length] > 4){
        NSLog(@"isOTR");
        isOTRMes= [[text substringToIndex:4] isEqualToString:@"?OTR"];
    } else {
        isOTRMes=NO;
    }
    
    if(!isOTRMes)
    {
        
        
        
        __block OTRBuddy *buddy = nil;
        [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            buddy = [message buddyWithTransaction:transaction];
        }];
        
        [self invalidatePausedChatStateTimerForBuddyUniqueId:buddy.uniqueId];
        
        if ([text length])
        {
            NSString * messageID = message.messageId;
            NSString * roomID = nil;
            
            //При отправке сообщения нас интересует тип сообщения (Групповое или Личное)
            NSString * messageType = @"";
            if(SafeJabTypeIsEqual(buddy.username, MUC_JABBER_HOST)){
                
                roomID =  [ [XMPPJID jidWithString:buddy.username] user];
                
               // [self sendPushForRoomFrom:self.account.username roomID:roomID body:message.text];
                
                messageType = @"groupchat";
                
            } else {
                messageType = @"chat";
            }
            
            
            
            
            XMPPMessage * xmppMessage = [XMPPMessage messageWithType:messageType to:[XMPPJID jidWithString:buddy.username] elementID:messageID];
            
            
            [xmppMessage addBody:@"SafeJab\nI can't open message!\nPlease update me :'("];
            
            
            NSXMLElement *securBody = [NSXMLElement elementWithName:@"securBody" stringValue:text];
            [xmppMessage addChild:securBody];
            
            
            NSXMLElement *lifeTime = [NSXMLElement elementWithName:@"lifeTime" stringValue:option];
            [xmppMessage addChild:lifeTime];
            
            
            
            [xmppMessage addActiveChatState];
            
         //   [self.xmppStream sendElement:xmppMessage];
            
            
            if([messageType isEqualToString:@"groupchat"]){
                
                NSString *from = [NSString stringWithFormat:@"%@/%@", buddy.username, self.account.username];
                [xmppMessage addAttributeWithName:@"from" stringValue:from];
                
                
                NSXMLElement *delay = [NSXMLElement elementWithName:@"delay" stringValue:@"placeToInsertDelay"];
                /*
                 [delay addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:delay"];
                 [delay addAttributeWithName:@"from" stringValue:MUC_JABBER_HOST];
                 [delay addAttributeWithName:@"stamp" stringValue:[MUCArhive timeStamp]];
                 */
                [xmppMessage addChild:delay];
                
                
                [MUCArhive saveRoomMessage:roomID message:(XMPPMessage *)xmppMessage from:self.account.username]; //Zig test
                
            } else {
                [self.xmppStream sendElement:xmppMessage];
            }
            
            
        }
    }
}

-(BOOL)isSecurBody:(XMPPMessage *)xmppMessage {
     NSString *securBody = [[xmppMessage elementForName:@"securBody"] stringValue];
    if(securBody.length > 0){
        return YES;
    }
    return NO;
    
}

-(void)sendIOpenSecurMessage:(OTRMessage *)mes buddyJID:(NSString *)JIDBuddy{
    
    
        XMPPMessage * xmppMessage = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:JIDBuddy] elementID:[[NSUUID UUID] UUIDString]];
    
        
   NSXMLElement *experiedTime = [NSXMLElement elementWithName:@"securlifeTime" stringValue:mes.lifeTime];
  [xmppMessage addChild:experiedTime];
    
    NSXMLElement *messageId = [NSXMLElement elementWithName:@"messageId" stringValue: mes.messageId];
    [xmppMessage addChild:messageId];
    
    
  [self.xmppStream sendElement:xmppMessage];
    
  
}

-(BOOL)isReceiveGroupMessageNeedUpdateRoomList:(XMPPMessage *)xmppMessage{
    //Пока не работает думаю нужна ли
    NSString *fromUser = [xmppMessage from].user;
    
    if([fromUser isEqualToString:USER_FOR_NOTIF_UPDATE_ROOM_LIST]){
    
        NSLog(@"USER_FOR_NOTIF_UPDATE_ROOM_LIST");
    }
    
    return NO;
}


-(BOOL)isReceiveGroupMessageReadAll:(XMPPMessage *)xmppMessage{
    
    
    //NSLog(@"isReceiveGroupMessageReadAll %@", xmppMessage);
    
    NSString *fromUser = [xmppMessage from].user;
    
    if([fromUser isEqualToString:USER_FOR_NOTIF]){
        
        NSString *messageId = [xmppMessage body];
        
        OTRMessage *tempMessage = [OTRMessage OTRMessageByMessageId:messageId];
        
        
        if(tempMessage.text.length == 0) return YES; //Если сообщения не существует то проигнорировать
        
    __block BOOL isSecur = tempMessage.lifeTime.length > 0 ? YES : NO;

       // isGroupMessageReadAll
     

        
        
        [self.databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            
            
            if(isSecur){
            //Если сообщение по таймеру удалить
                NSDate *now = [NSDate date];
                NSDate *dateNowPlus10s = [NSDate dateWithTimeInterval:+10 sinceDate:now];
                [OTRMessage receivedIReadExpiredMessageForMessageId:messageId experiedDate:dateNowPlus10s transaction:transaction];
                
            } else {
                //Если без таймера то установить флаг что все в групп чате прочитали его
                [OTRMessage receivedDeliveryReceiptForMessageId:messageId transaction:transaction];
                
            }
        }];
        
        
        return YES;
        
        
    }
    
    return NO;
    
  //NSString * messageId  =  [xmppMessage body];
    
}

-(BOOL)isReciveIOpenSecurMessage:(XMPPMessage *)xmppMessage {
    NSString *securlifeTime = [[xmppMessage elementForName:@"securlifeTime"] stringValue];
    if(securlifeTime.length > 0){
        
        NSString *messageId = [[xmppMessage elementForName:@"messageId"] stringValue];
        NSDate * dateMessage = [xmppMessage delayedDeliveryDate];
        
        if(!dateMessage){
           dateMessage = [NSDate date];
        }
        
        
 
        NSTimeInterval lifeTime = [securlifeTime intValue];
        NSDate *securExperiedTime = [NSDate dateWithTimeInterval:+lifeTime
                                                       sinceDate:dateMessage];
        
        
      //   NSString *forLog =  dateToStringWithMask(securExperiedTime, @"d.m.Y H:m:s");
    
     //   NSLog(@"securExperiedTime %@", forLog);
        
        [self.databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
            [OTRMessage receivedIReadExpiredMessageForMessageId:messageId experiedDate:securExperiedTime transaction:transaction];
        }];
        
        return YES;
    }
    return NO;
}

#pragma mark - Прием групповых сообщений
-(void)setTimerMUCArchive{
    
    if(!self.timerMUCArchive){
        
        self.timerMUCArchive = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                         target: self
                                                       selector: @selector(actionTimerMUCArchive)
                                                       userInfo: nil
                                                        repeats: YES];
    }
}

-(void)clearTimerMUCArchive{
    [self.timerMUCArchive invalidate];
    self.timerMUCArchive = nil;
}


-(void)actionTimerMUCArchive{
    
   
    
   // [groupChatManager checkCounRooms];
    
    NSArray *rooms  =   [[groupChatManager sharedRoomsWithFriends] allKeys];
    
    
    if(rooms.count >0){
        
        for(NSString *roomID in rooms){
            
            
            [self joinRoomById:roomID];
            
             NSString* fullRoomID = [NSString stringWithFormat:@"%@@%@", roomID, MUC_JABBER_HOST];
            
            [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                if([OTRBuddy fetchBuddyWithUsername:fullRoomID withAccountUniqueId:self.account.uniqueId transaction:transaction]){
                   [self receiveAllMessagesByRoomId:roomID];
                }
            }];
            
            
            
            
            
        }
        
    }

}



-(void)receiveAllMessagesByRoomId:(NSString *)roomID{
    [MUCArhive getRoomMessages:(NSString *)roomID toAccount:self.account.username];
    
  //  [self xmppStream:self.xmppStream didReceiveMessage:(XMPPMessage *)xmppMessage];
    
}

-(void)receiveMessageForRoom:(NSString *)strMessage{
    
    XMPPMessage * XMPPMes = [[XMPPMessage alloc] initWithXMLString:strMessage error:nil];
    

    
  //NSLog(@"XMPPMesFrom %@", [XMPPMes type]) ;
   //     NSString *body = [[XMPPMes elementForName:@"body"] stringValue];
    
  //  NSLog(@"BodyRecive %@", body);
    
    dispatch_async(dispatch_get_main_queue(), ^{
    [self xmppStream:self.xmppStream didReceiveMessage:XMPPMes];
    });
    
    
}

#pragma mark - Room функционал
- (void)sendInvite:(NSString*)buddyUsername roomID: (NSString* )roomID
{
   
    NSLog(@"IS OLD FUNCTION sendInvite");
    /*
    
    //Надеюсь что так отправлю приглащение к групповому чату :(
    
    // OTRBuddy *buddy = [OTRBuddy fetchBuddyForUsername:username accountName:accountName transaction:transaction];
    
    XMPPMessage * xmppMessage = [XMPPMessage messageWithType:@"normal" to:[XMPPJID jidWithString:buddyUsername] elementID:[[NSUUID UUID] UUIDString]];
    
    
    
    [xmppMessage addSubject:@"invite"];
    [xmppMessage addBody:roomID];
    
    
    //Тут реально отправка через XMPP
    [self.xmppStream sendElement:xmppMessage];
    */
    
}


-(void)sendPushForRoomFrom:(NSString *)from roomID:(NSString *)roomID body:(NSString *)body{
    
    
    NSArray *strArr = [from componentsSeparatedByString:@"@"];
    
    if(strArr.count >= 2){
        
        from = [strArr firstObject];
    }
    
    
    NSString *str = [NSString stringWithFormat:@"https://safejab.com/apns.php?task=msg&to=%@&from=%@&body=%@", roomID, from, @"Test"];
    
    
    NSURL *url = [NSURL URLWithString:str];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(error) NSLog(@"Error sendAsynchronousRequest");
    }];
}

-(void) sendImAddFriend:(NSString*)buddyUsername roomID: (NSString* )roomID{
    
   
    
    NSString *roomIDFull = [NSString stringWithFormat:@"%@@%@", roomID, MUC_JABBER_HOST];
    
    XMPPMessage * xmppMessage = [XMPPMessage messageWithType:@"groupchat" to:[XMPPJID jidWithString:roomIDFull] elementID:[[NSUUID UUID] UUIDString]];
    
    NSString *from = [NSString stringWithFormat:@"%@/%@", roomIDFull, self.account.username];
    [xmppMessage addAttributeWithName:@"from" stringValue:from];
    
    [xmppMessage addSubject:@"addFriend"];
    [xmppMessage addBody:[NSString stringWithFormat:@"%@ %@ %@",  self.account.username, INVITE_TO_CHAT, buddyUsername]];
    
    // [self.xmppStream sendElement:xmppMessage];
    [MUCArhive saveRoomMessage:roomID message:xmppMessage from:self.account.username];
    
   
    
}

-(void) sendBye:(NSString*)buddyUsername roomID: (NSString* )roomID{
    
    NSString *roomIDFull = [NSString stringWithFormat:@"%@@%@", roomID, MUC_JABBER_HOST];
    
    XMPPMessage * xmppMessage = [XMPPMessage messageWithType:@"groupchat" to:[XMPPJID jidWithString:roomIDFull] elementID:[[NSUUID UUID] UUIDString]];
    
    NSString *from = [NSString stringWithFormat:@"%@/%@", roomIDFull, self.account.username];
    [xmppMessage addAttributeWithName:@"from" stringValue:from];
    
    [xmppMessage addSubject:@"bye"];
    [xmppMessage addBody:[NSString stringWithFormat:@"%@\n%@", buddyUsername, LEAVE_THE_ROOM]];
    
    
    // [self.xmppStream sendElement:xmppMessage];
    [MUCArhive saveRoomMessage:roomID message:xmppMessage from:self.account.username];
    
}

-(void)sendRenameRoom:(NSString*)buddyUsername roomID: (NSString* )roomID {
    
    NSString *roomIDFull = [NSString stringWithFormat:@"%@@%@", roomID, MUC_JABBER_HOST];
    
    XMPPMessage * xmppMessage = [XMPPMessage messageWithType:@"groupchat" to:[XMPPJID jidWithString:roomIDFull] elementID:[[NSUUID UUID] UUIDString]];
    
    NSString *from = [NSString stringWithFormat:@"%@/%@", roomIDFull, self.account.username];
    [xmppMessage addAttributeWithName:@"from" stringValue:from];
    
    [xmppMessage addSubject:@"renameRoom"];
    [xmppMessage addBody:[NSString stringWithFormat:@"%@ %@", buddyUsername, RENAMED_ROOM]];
    
    
    // [self.xmppStream sendElement:xmppMessage];
    [MUCArhive saveRoomMessage:roomID message:xmppMessage from:self.account.username];
    
}

#pragma mark - presence

-(void)sendSubscribedToJid:(NSString *)jid{
    
    XMPPPresence * pesence = [[XMPPPresence alloc] initWithType:@"subscribed" to:[XMPPJID jidWithString:jid]];

    
    [self.xmppStream sendElement:pesence];
    
}

-(void)sendUpdateRoomPresence:(NSString *)roomId{
    
    XMPPPresence * pesence = [[XMPPPresence alloc] initWithType:@"roomPresence"];
    
    [pesence addAttributeWithName:@"updateRoom" stringValue:roomId];
    
    [self.xmppStream sendElement:pesence];
    
}

-(void)receiveUpdateRoomPresence:(XMPPPresence *)pesence{
    
   // self.account
    
    
    
    //NSString *roomId = [[pesence attributeForName:@"updateRoom"] stringValue];
    
    NSString * from = [NSString stringWithFormat:@"%@@%@", [pesence from].user,[pesence from].domain];
    
    

    if(from.length > 5 && ![self.account.username isEqualToString:from]){
    
    //NSString *fullRoomID = [NSString stringWithFormat:@"%@@%@", roomId, MUC_JABBER_HOST];
    
    
        
        [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
         OTRBuddy * buddy = [OTRBuddy fetchBuddyWithUsername:from withAccountUniqueId:self.account.uniqueId transaction:transaction];
            
            if(buddy.username.length > 0){
                [groupChatManager updateRoomsWithFriends];
            }
            
        }];
    }
}



@end

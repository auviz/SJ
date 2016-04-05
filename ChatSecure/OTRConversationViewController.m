//
//  OTRConversationViewController.m
//  Off the Record
//
//  Created by David Chiles on 3/2/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import "OTRConversationViewController.h"

#import "OTRSettingsViewController.h"
#import "OTRComposeViewController.h"
#import "OTRSubscriptionRequestsViewController.h"

#import "OTRConversationCell.h"
#import "OTRNotificationPermissions.h"
#import "OTRAccount.h"
#import "OTRBuddy.h"
#import "OTRMessage.h"
#import "UIViewController+ChatSecure.h"
#import "OTRLog.h"
#import "YapDatabaseView.h"
#import "YapDatabase.h"
#import "OTRDatabaseManager.h"
#import "YapDatabaseConnection.h"
#import "OTRDatabaseView.h"
#import "YapDatabaseViewMappings.h"

#import "OTROnboardingStepsController.h"
#import "OTRAppDelegate.h"

#import "groupChatManager.h"
#import "OTRRoom.h"
#import "OTRTabBar.h"



static CGFloat kOTRConversationCellHeight = 80.0;

@interface OTRConversationViewController () <OTRComposeViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSTimer *cellUpdateTimer;
@property (nonatomic, strong) YapDatabaseConnection *connection;
@property (nonatomic, strong) YapDatabaseViewMappings *mappings;
@property (nonatomic, strong) YapDatabaseViewMappings *subscriptionRequestsMappings;
@property (nonatomic, strong) YapDatabaseViewMappings *unreadMessagesMappings;
//@property  id staticTabBar;
@property (nonatomic, strong) OTRTabBar * tabBar;
@property (nonatomic, strong) NSMutableDictionary *dictObjMessagesViewController;
@property (nonatomic, strong) UIBarButtonItem *composeBarButtonItem;
@property dispatch_queue_t myQueue;


@property NSTimer *timerWaitingConnection;
@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic,strong) UIView *titleView;
@end

@implementation OTRConversationViewController

@synthesize timerWaitingConnection;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
   // [groupChatManager willJoinAllRooms];
   // [self timerForUpdateRooms];
    
    
   // self.staticTabBar = [[OTRTabBar alloc] init];
    
    
    
    self.dictObjMessagesViewController = [[NSMutableDictionary alloc] init]; //Словарь экземпляров для Buddy
    
    
    
    ////// Reset buddy status //////
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [OTRBuddy resetAllBuddyStatusesWithTransaction:transaction];
        [OTRBuddy resetAllChatStatesWithTransaction:transaction];
    }];
    
    
    ///////////// Setup Navigation Bar //////////////
    
    self.title = CHATS_STRING;
    /*
    UIBarButtonItem *settingsBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"OTRSettingsIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonPressed:)];
    self.navigationItem.rightBarButtonItem = settingsBarButtonItem;
    
    self.composeBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonPressed:)];
    self.navigationItem.leftBarButtonItem = self.composeBarButtonItem;
    */
    
    self.composeBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonPressed:)];
    self.navigationItem.rightBarButtonItem = self.composeBarButtonItem;
    
    
    ////////// Create TableView /////////////////
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = kOTRConversationCellHeight;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[OTRConversationCell class] forCellReuseIdentifier:[OTRConversationCell reuseIdentifier]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:0 views:@{@"tableView":self.tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|" options:0 metrics:0 views:@{@"tableView":self.tableView}]];
    
    ////////// Create YapDatabase View /////////////////
    
    self.connection = [OTRDatabaseManager sharedInstance].mainThreadReadOnlyDatabaseConnection;
    
    self.mappings = [[YapDatabaseViewMappings alloc] initWithGroups:@[OTRConversationGroup]
                                                               view:OTRConversationDatabaseViewExtensionName];
    self.subscriptionRequestsMappings = [[YapDatabaseViewMappings alloc] initWithGroups:@[OTRAllPresenceSubscriptionRequestGroup]
                                                                                   view:OTRAllSubscriptionRequestsViewExtensionName];
    self.unreadMessagesMappings = [[YapDatabaseViewMappings alloc] initWithGroupFilterBlock:^BOOL(NSString *group, YapDatabaseReadTransaction *transaction) {
        return YES;
    } sortBlock:^NSComparisonResult(NSString *group1, NSString *group2, YapDatabaseReadTransaction *transaction) {
        return NSOrderedSame;
    } view:OTRUnreadMessagesViewExtensionName];
    
    
    
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [self.mappings updateWithTransaction:transaction];
        [self.subscriptionRequestsMappings updateWithTransaction:transaction];
        [self.unreadMessagesMappings updateWithTransaction:transaction];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(yapDatabaseModified:)
                                                 name:OTRUIDatabaseConnectionDidUpdateNotification
                                               object:nil];
    
   // [self tryToUpdateSharedroomsWithFriends];
    
     [self.tableView setContentInset:UIEdgeInsetsMake(0,0,50,0)];
    
     [self setupIndicatorView];
    

}

-(void)tryToUpdateSharedroomsWithFriends{

    dispatch_async(dispatch_get_main_queue(), ^{
    
          
    groupChatManager * GCM  = [[groupChatManager alloc] init];
    [GCM updateListSync];
    
        
    });
    
 
    
}

-(void)didErrorGroupChat{
    //Если возникает ошибка проинформировать алертом
    [groupChatManager showAlertGroupChat:self];
    
}

-(void)reloadTableViewCollection{
    
    DDLogInfo(@"reloadTableViewCollection");
  //  [self.tableView reloadData];
    [self updateVisibleCells:self];
}


- (void)userLeaveRoom:(NSNotification*)notification {
    
    DDLogInfo(@"ZZZZuserLeaveRoom");
 
   // if([groupChatManager sharedRoomsWithFriends].count == 0 ) return; //Чтоб не впадать в рекурсию
   
   // [groupChatManager willJoinAllRooms];
    [self updateVisibleCells:self];
  //  [self timerForUpdateRooms];
    
    
}


-(void)viewWillLayoutSubviews {
    if(self.tabBar){
         [self.tabBar setTBFrame:CGRectMake(0, (self.view.frame.size.height -50), self.view.frame.size.width, 50)];
    }
    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    

    
    //[self.tableView setContentInset:UIEdgeInsetsMake(0,0,50,0)];
    //[self.tableView reloadData];
    
    
  
    if(!self.tabBar){
    
    self.tabBar = [[OTRTabBar alloc] init];
    
    [self.tabBar addTabBar:self.view];
        
    } else {
        [self.tabBar addTabBar:self.view];
    }
  
    [self.tabBar setTBFrame:CGRectMake(0, (self.view.frame.size.height -50), self.view.frame.size.width, 50)];
    
    
    
    [self.cellUpdateTimer invalidate];
    [self.tableView reloadData];
    [self updateInbox];
    [self updateTitle];
    self.cellUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(updateVisibleCells:) userInfo:nil repeats:YES];
    
    if([OTRProtocolManager sharedInstance].numberOfConnectedProtocols){
        [self enableComposeButton];
  
     
    }
    else {
        [self disableComposeButton];
    }
    
    [[OTRProtocolManager sharedInstance] addObserver:self forKeyPath:NSStringFromSelector(@selector(numberOfConnectedProtocols)) options:NSKeyValueObservingOptionNew context:NULL];
   
    
    //Zig init
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLeaveRoom:)
                                                 name:NOTIFICATION_UPDATE_ROOM_LIST
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableViewCollection)
                                                 name:NOTIFICATION_NEED_RELOAD_COLLECTION
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didErrorGroupChat)
                                                 name:NOTIFICATION_DID_ERROR_GROUP_CHAT
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setTimerWaitingConnection)
                                                 name:NOTIFICATION_XMPP_STREAM_DID_DISCONNECT
                                                    object:nil];
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLeaveRoom:)
                                                 name:@"userRenameRoom"
                                               object:nil];
     */

    
    
    [self setTimerWaitingConnection];
    
   // self.navigationController.toolbarHidden =NO;
   
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
      [self clearTimerWaitingConnection];
}

-(void)ifNotAccountGoToLogin{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        __block NSArray *accounts = nil;
        [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            accounts = [OTRAccount allAccountsWithTransaction:transaction];
        }];
        
        if(accounts.count == 0){
        
        OTRAccount *account = [OTRAccount accountForAccountType:OTRAccountTypeJabber];
        
        
        OTRLoginViewController *loginViewController = [OTRLoginViewController loginViewControllerWithAcccount:account];
        loginViewController.isNewAccount = YES;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];
        }
        
    });
    

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [OTRNotificationPermissions checkPermissions];
    [self ifNotAccountGoToLogin];
    
    
    

    
   
    
    
  // [self.bar addItemsToUINavigationController:self.navigationController];

    

    

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.cellUpdateTimer invalidate];
    self.cellUpdateTimer = nil;
    
    [[OTRProtocolManager sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(numberOfConnectedProtocols))];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_UPDATE_ROOM_LIST object:nil];
       [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NEED_RELOAD_COLLECTION object:nil];
      [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_DID_ERROR_GROUP_CHAT object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_XMPP_STREAM_DID_DISCONNECT object:nil];
   // [[NSNotificationCenter defaultCenter] removeObserver:self name:@"userRenameRoom" object:nil];
    

}

- (void)settingsButtonPressed:(id)sender
{
    OTRSettingsViewController * settingsViewController = [[OTRSettingsViewController alloc] init];
    
    [self.navigationController pushViewController:settingsViewController animated:NO];
}

- (void)composeButtonPressed:(id)sender
{
  //  /*

    OTRComposeViewController * composeViewController = [[OTRComposeViewController alloc] initWithHidenTabBar];
    composeViewController.delegate = self;
    
    [self.navigationController pushViewController:composeViewController animated:YES];
   
    /*
    UINavigationController * modalNavigationController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    modalNavigationController.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:modalNavigationController animated:YES completion:nil];
     */
  //  */
    
  //  [self.bar leftButtonPressed];
}

-(OTRMessagesViewController *)getMessagesView:(NSString *)buddyUniqueId
{
    OTRMessagesViewController *temp = [self.dictObjMessagesViewController objectForKey:buddyUniqueId];
    
    if(temp) return temp; else return nil;
}

-(OTRMessagesViewController *)generateMessagesView:(OTRBuddy *)buddy{
    
    OTRMessagesViewController *clone = [OTRMessagesViewController messagesViewController];
    
    clone.buddy = buddy;
    
   // OTRMessagesViewController.h
    if(buddy.uniqueId){
    [self.dictObjMessagesViewController setObject:clone forKey:buddy.uniqueId];
    }
    return clone;
}


-(OTRMessagesViewController *)messagesViewControllerWithBuddy:(OTRBuddy *)buddy{
    
    OTRMessagesViewController *messagesViewController;
    
    if (buddy) {
        [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [buddy setAllMessagesRead:transaction];
        }];
    }
    
    
    OTRMessagesViewController *temp = [self getMessagesView:buddy.uniqueId];
    
    if(temp){
        //Если есть экземпляр в словаре использовать его
        messagesViewController = temp;
        
    } else {
        //Иначе сделать его копию и потом использовать ее
        
        // messagesViewController = [OTRAppDelegate appDelegate].messagesViewController;
        //  messagesViewController.buddy = buddy;
        
        messagesViewController =  [self generateMessagesView:buddy];
        
        
        // messagesViewController = [self getMessagesView:buddy.uniqueId];
    }
    
    
    [OTRAppDelegate appDelegate].messagesViewController = messagesViewController;
    
    return messagesViewController;
    
}



- (void)enterConversationWithBuddy:(OTRBuddy *)buddy
{
    OTRMessagesViewController *messagesViewController = [self messagesViewControllerWithBuddy:buddy];
    
    
    
   // if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && ![messagesViewController otr_isVisible]) {
        [self.navigationController pushViewController:messagesViewController animated:YES];
  //  }
    
}

- (void)enterConversationWithBuddyNoAnimition:(OTRBuddy *)buddy
{
    OTRMessagesViewController *messagesViewController = [self messagesViewControllerWithBuddy:buddy];
    
    
    
    // if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && ![messagesViewController otr_isVisible]) {
    [self.navigationController pushViewController:messagesViewController animated:NO];
    //  }
    
}

- (void)updateVisibleCells:(id)sender
{
 
    
    NSArray * indexPathsArray = [self.tableView indexPathsForVisibleRows];
    

    
    for(NSIndexPath *indexPath in indexPathsArray)
    {
        OTRBuddy *buddy = [self buddyForIndexPath:indexPath];
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[OTRConversationCell class]]) {
            [(OTRConversationCell *)cell setBuddy:buddy];
        }
    }
}

-(dispatch_queue_t)getMyQueue {
    
    if(!self.myQueue ) {
        self.myQueue =  dispatch_queue_create("ROOM.queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self.myQueue;
    
    
}

-(void)timerForUpdateRooms{
    
    return;
    
    DDLogCInfo(@"timerForUpdateRooms");
    
    BOOL isRequestError =[groupChatManager sharedIsRequestError];
 
    
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), [self getMyQueue], ^{
            
            
        if(isRequestError) [self timerForUpdateRooms]; else {
            [self updateVisibleCells:self];
        }
        
        
        
    });
    
    
    
    
    ///  NSLog(@"ziuuuuu %@", buddy);
    
    
    
    
    
    // if ([self.delegate respondsToSelector:@selector(controller:didSelectBuddy:)]) {
    //    [self.delegate controller:self didSelectBuddy:buddy];
    // }
    
    
}



-(void)deleteOldRooms:(OTRBuddy*)buddy{
    
  //  return; //NEED TO FIX IT
    
    if(!buddy) return ;
    
    
    BOOL isError = [groupChatManager sharedIsRequestError];
    // NSLog(@"willJoinAllRooms %@, %d", test, test2);
    
    if(isError) return ;

    
    if(!SafeJabTypeIsEqual(buddy.username, MUC_JABBER_HOST)) return ;
    
    NSString *roomId = buddy.username;
    
    
    if(!roomId) return ;
    
    
    
    NSArray *strArr = [roomId componentsSeparatedByString:@"@"];
    
    if(strArr.count >= 2){
        
        roomId = [strArr firstObject];
    }
    
    
    
   // if([roomId isEqualToString:@"group"]) return ;
    
    
    NSMutableDictionary *rooms  =   [groupChatManager sharedRoomsWithFriends];
    
 

    
    if([rooms objectForKey:roomId]) return ;
    
    
    __block OTRAccount *buddyAccount = nil;
    [[OTRDatabaseManager sharedInstance].mainThreadReadOnlyDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        buddyAccount = [OTRAccount fetchObjectWithUniqueID:buddy.accountUniqueId transaction:transaction];
    }];
    
     dispatch_async(dispatch_get_main_queue(), ^{
    //Выхожу из комнаты
    [[[OTRProtocolManager sharedInstance] protocolForAccount:buddyAccount] removeBuddies:@[buddy]];
    
   // OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:SJAccount()];
    
  //  XMPPRoom *xmppRoom = [xmppManager getSJRooms:roomId];
    
  //  [xmppRoom leaveRoom];
    
 //   [xmppManager deleteSJRoomFromDic:xmppRoom];
         
     });
    
    
    return YES;
}

- (OTRBuddy *)buddyForIndexPath:(NSIndexPath *)indexPath
{
    
    __block OTRBuddy *buddy = nil;
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        buddy = [[transaction extension:OTRConversationDatabaseViewExtensionName] objectAtIndexPath:indexPath withMappings:self.mappings];
    }];
    
    
     dispatch_async(dispatch_get_main_queue(), ^{
    [self deleteOldRooms: buddy];
     });
    
    return buddy;
}

- (void)enableComposeButton
{
    self.composeBarButtonItem.enabled = YES;
}

- (void)disableComposeButton
{
    self.composeBarButtonItem.enabled = NO;
}

#pragma KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSUInteger numberConnectedAccounts = [[change objectForKey:NSKeyValueChangeNewKey] unsignedIntegerValue];
    if (numberConnectedAccounts) {
        [self enableComposeButton];
        
    }
    else {
        [self disableComposeButton];
    }
}

#pragma - mark Inbox Methods

- (void)showInbox
{
    if ([self.navigationItem.leftBarButtonItems count] != 2) {
        UIBarButtonItem *inboxBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"inbox"] style:UIBarButtonItemStylePlain target:self action:@selector(inboxButtonPressed:)];
        
        self.navigationItem.leftBarButtonItems = @[self.composeBarButtonItem,inboxBarButtonItem];
    }
}

- (void)hideInbox
{
    if ([self.navigationItem.leftBarButtonItems count] > 1) {
        self.navigationItem.leftBarButtonItem = self.composeBarButtonItem;
    }
    
}

- (void)inboxButtonPressed:(id)sender
{

    OTRSubscriptionRequestsViewController *viewController = [[OTRSubscriptionRequestsViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)updateInbox
{
    if ([self.subscriptionRequestsMappings numberOfItemsInAllGroups] > 0) {
        [self showInbox];
    }
    else {
        [self hideInbox];
    }
}

- (void)updateTitle
{
    NSUInteger numberUnreadMessages = [self.unreadMessagesMappings numberOfItemsInAllGroups];
    [OTRTabBar setBadgeChats:numberUnreadMessages];
    
    if (numberUnreadMessages > 99) {
        self.title = [NSString stringWithFormat:@"%@ (99+)",CHATS_STRING];
    }
    else if (numberUnreadMessages > 0)
    {
        self.title = [NSString stringWithFormat:@"%@ (%ld)",CHATS_STRING,(unsigned long)numberUnreadMessages];
    }
    else {
        self.title = CHATS_STRING;
    }
}


#pragma - mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.mappings numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.mappings numberOfItemsInSection:section];
}

-(void)deleteRoomGroupChatForCellBuddy:(OTRBuddy *)cellBuddy{
  
    
    
    __block OTRAccount *buddyAccount = nil;
    [[OTRDatabaseManager sharedInstance].mainThreadReadOnlyDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        buddyAccount = [OTRAccount fetchObjectWithUniqueID:cellBuddy.accountUniqueId transaction:transaction];
    }];
    
    
    
 OTRRoom * room =  [OTRRoom roomById:cellBuddy.username];
    groupChatManager *GCM = [[groupChatManager alloc] init];
    
    if([buddyAccount.username isEqualToString:room.roomAdmin]){
        //Если удаляет создатель разрушить комнату
       
        [GCM deleteOrLeaveTheRoom:room.roomId];
        GCM.needDestroyRoomWithId = room.roomId; //Удаляем комнату на сервере если являемся админом комнаты
 
    } else {
        //Или просто покинуть комнату
        //[GCM sendByeForRoomID:room.roomId];
        [GCM deleteOrLeaveTheRoom:room.roomId];
        GCM.needLeaveRoomWithId = room.roomId;
    }

    
    
    [[[OTRProtocolManager sharedInstance] protocolForAccount:buddyAccount] removeBuddies:@[cellBuddy]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Delete conversation
    //zigzagcorp delete
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        OTRBuddy *cellBuddy =  [(OTRConversationCell *)[tableView cellForRowAtIndexPath:indexPath] welfBody];
        
         BOOL isGroupChat = SafeJabTypeIsEqual(cellBuddy.username, MUC_JABBER_HOST);
        
        
        if(isGroupChat){
            
            [self deleteRoomGroupChatForCellBuddy:cellBuddy];
            
        } else {
            
        
        [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [OTRMessage deleteAllMessagesForBuddyId:cellBuddy.uniqueId transaction:transaction];
        }];
            
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{


    
    
    
    OTRConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:[OTRConversationCell reuseIdentifier] forIndexPath:indexPath];
    OTRBuddy * buddy = [self buddyForIndexPath:indexPath];
    
    
 
    
    [cell.avatarImageView.layer setCornerRadius:(kOTRConversationCellHeight-2.0*OTRBuddyImageCellPadding)/2.0];
    
    [cell setBuddy:buddy];
    
    
    return cell;
}

#pragma - mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kOTRConversationCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kOTRConversationCellHeight;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    OTRBuddy *buddy = [self buddyForIndexPath:indexPath];
    [self enterConversationWithBuddy:buddy];
   // if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
 //   }
}

#pragma - mark YapDatabse Methods

- (void)yapDatabaseModified:(NSNotification *)notification
{
    NSArray *notifications = notification.userInfo[@"notifications"];
    
    NSArray *sectionChanges = nil;
    NSArray *rowChanges = nil;
    
    [[self.connection ext:OTRConversationDatabaseViewExtensionName] getSectionChanges:&sectionChanges
                                                                           rowChanges:&rowChanges
                                                                     forNotifications:notifications
                                                                         withMappings:self.mappings];
    
    NSArray *subscriptionSectionChanges = nil;
    NSArray *subscriptionRowChanges = nil;
    [[self.connection ext:OTRAllSubscriptionRequestsViewExtensionName] getSectionChanges:&subscriptionSectionChanges
                                                                              rowChanges:&subscriptionRowChanges
                                                                        forNotifications:notifications
                                                                            withMappings:self.subscriptionRequestsMappings];
    
    if ([subscriptionSectionChanges count] || [subscriptionRowChanges count]) {
        [self updateInbox];
    }
    
    NSArray *unreadMessagesSectionChanges = nil;
    NSArray *unreadMessagesRowChanges = nil;
    
    [[self.connection ext:OTRUnreadMessagesViewExtensionName] getSectionChanges:&unreadMessagesSectionChanges
                                                                     rowChanges:&unreadMessagesRowChanges
                                                               forNotifications:notifications
                                                                   withMappings:self.unreadMessagesMappings];
    
    if ([unreadMessagesSectionChanges count] || [unreadMessagesRowChanges count]) {
        [self updateTitle];
    }
    
    // No need to update mappings.
    // The above method did it automatically.
    
    if ([sectionChanges count] == 0 && [rowChanges count] == 0)
    {
        // Nothing has changed that affects our tableView
        return;
    }
    
    // Familiar with NSFetchedResultsController?
    // Then this should look pretty familiar
    
    [self.tableView beginUpdates];
    
    for (YapDatabaseViewSectionChange *sectionChange in sectionChanges)
    {
        switch (sectionChange.type)
        {
            case YapDatabaseViewChangeDelete :
            {
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeInsert :
            {
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeUpdate:
            case YapDatabaseViewChangeMove:
                break;
        }
    }
    
    for (YapDatabaseViewRowChange *rowChange in rowChanges)
    {
        switch (rowChange.type)
        {
            case YapDatabaseViewChangeDelete :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeInsert :
            {
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeMove :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeUpdate :
            {
                [self.tableView reloadRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
    
    [self.tableView endUpdates];
}

#pragma - mark OTRComposeViewController Method

- (void)controller:(OTRComposeViewController *)viewController didSelectBuddy:(OTRBuddy *)buddy
{
    [viewController dismissViewControllerAnimated:YES completion:^{
        [self enterConversationWithBuddy:buddy];
    }];
}


//Таймер ожидания подключения

-(void)setTimerWaitingConnection{
    
     dispatch_async(dispatch_get_main_queue(), ^{
    
    BOOL isConnected = [self isConnected];
    
    
    if(self.timerWaitingConnection) [self clearTimerWaitingConnection];
    
    
    if (isConnected) {
        
        [self stopIndicatorView];
        return; }
    
    //Если нет поключения запустить таймер
    
    if(!isConnected){
        [self startIndicatorView];
        [self checkConnection];
        self.timerWaitingConnection = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                                       target: self
                                                                     selector: @selector(checkConnection)
                                                                     userInfo: nil
                                                                      repeats: YES];
        
    }
});
    
}



-(BOOL)isConnected {
    

    
    // self.account
   // BOOL isConnected =   [[OTRAccountsManager allAccountsAbleToAddBuddies] count] > 0 ? YES : NO;
    BOOL isConnected = isConnectedSJAccount();
    
    
    if(isConnected){
        return YES;
    } else {
        return NO;
    }
}

-(void)checkConnection {
    
    
    if([self isConnected]){
        
        [self stopIndicatorView];
        
        [self clearTimerWaitingConnection];
        
    } else {
        
        
      //    NSLog(@"NOTconnect %d", (int)count);
        
        [self startIndicatorView];
        
        
    }
    
}

-(void)clearTimerWaitingConnection{
    [self.timerWaitingConnection invalidate];
    self.timerWaitingConnection = nil;
}

-(void)startIndicatorView {
    
    if(![self.indicatorView isAnimating]){
        
        [self.indicatorView startAnimating];
        
         self.navigationItem.titleView=self.indicatorView;
        
       // self.self.navigationItem.titleView.alpha = 0;
        
        
      //  self.titleView.titleLabel.alpha = 0;
       // self.titleView.subtitleLabel.alpha=0;
        
      
        
    }
}

-(void)stopIndicatorView {
    
    [self.indicatorView stopAnimating];
    
     self.navigationItem.titleView=self.titleView;
    
    /*
    
    if(self.titleView.titleLabel.alpha == 0){
        
        // начинаем анимацию
        [UIView beginAnimations:nil context:nil];
        // продолжительность анимации - 1 секунда
        [UIView setAnimationCurve:2.0];
        // пауза перед началом анимации - 1 секунда
        // [UIView setAnimationDelay:1.0];
        // тип анимации устанавливаем - "начало медленное - конец быстрый"
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        // собственно изменения, которые будут анимированы
        self.titleView.titleLabel.alpha = 1;
        self.titleView.subtitleLabel.alpha=1;
        
        // команда, непосредственно запускающая анимацию.
        [UIView commitAnimations];
        
    }
     
     */
    
}

-(void)setupIndicatorView{
    //Добавление индикатора
    
    
    
    self.indicatorView = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //CGRect frame =  self.navigationItem.titleView.frame;
   // CGRect titleFrame =   self.indicatorView.frame;
    
  //  frame.origin.x = frame.size.width / 2 - titleFrame.size.width / 2;
   // frame.origin.y = frame.size.height / 2 - titleFrame.size.height / 2;
   // self.indicatorView.frame = frame;
    
    self.titleView = self.navigationItem.titleView;
    
    
}



@end
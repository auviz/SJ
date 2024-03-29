//
//  OTRDatabaseView.m
//  Off the Record
//
//  Created by David Chiles on 3/31/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import "OTRDatabaseView.h"
#import "YapDatabaseView.h"
#import "YapDatabase.h"
#import "OTRDatabaseManager.h"
#import "OTRBuddy.h"
#import "OTRAccount.h"
#import "OTRMessage.h"
#import "OTRXMPPPresenceSubscriptionRequest.h"
#import "YapDatabaseFullTextSearch.h"
#import "YapDatabaseFilteredView.h"

#import "OTRYapPushAccount.h"
#import "OTRYapPushDevice.h"
#import "OTRYapPushToken.h"
#import "OTRAccountsManager.h"
#import "SetGlobVar.h"
#import "groupChatManager.h"

NSString *OTRConversationGroup = @"Conversation";
NSString *OTRConversationDatabaseViewExtensionName = @"OTRConversationDatabaseViewExtensionName";
NSString *OTRChatDatabaseViewExtensionName = @"OTRChatDatabaseViewExtensionName";
NSString *OTRBuddyDatabaseViewExtensionName = @"OTRBuddyDatabaseViewExtensionName";
NSString *OTRBuddyNameSearchDatabaseViewExtensionName = @"OTRBuddyBuddyNameSearchDatabaseViewExtensionName";
NSString *OTRAllBuddiesDatabaseViewExtensionName = @"OTRAllBuddiesDatabaseViewExtensionName";
NSString *OTRAllSubscriptionRequestsViewExtensionName = @"AllSubscriptionRequestsViewExtensionName";
NSString *OTRAllPushAccountInfoViewExtensionName = @"OTRAllPushAccountInfoViewExtensionName";
NSString *OTRUnreadMessagesViewExtensionName = @"OTRUnreadMessagesViewExtensionName";

NSString *OTRAllAccountGroup = @"All Accounts";
NSString *OTRAllAccountDatabaseViewExtensionName = @"OTRAllAccountDatabaseViewExtensionName";
NSString *OTRChatMessageGroup = @"Messages";
NSString *OTRBuddyGroup = @"Buddy";
NSString *OTRAllPresenceSubscriptionRequestGroup = @"OTRAllPresenceSubscriptionRequestGroup";
NSString *OTRUnreadMessageGroup = @"Unread Messages";

NSString *OTRPushTokenGroup = @"Tokens";
NSString *OTRPushDeviceGroup = @"Devices";
NSString *OTRPushAccountGroup = @"Account";

@implementation OTRDatabaseView

+(BOOL)isComposeCurAccount:(NSString *)buddyUsername
{
    
    //zigzagcorp function
    
    if([buddyUsername isEqualToString:[OTRAccountsManager accountWithUsername:buddyUsername].username]) return YES; //zigzagcorp test
    return NO;
    
    
    
}

+(BOOL)isGroupChat:(NSString *)buddyUsername {
    
    

    
    if(SafeJabTypeIsEqual(buddyUsername, MUC_JABBER_HOST)) {

        return YES;
    } else {
        
        return NO;
    }
    
}



+ (BOOL)registerConversationDatabaseView
{
    YapDatabaseView *conversationView = [[OTRDatabaseManager sharedInstance].database registeredExtension:OTRConversationDatabaseViewExtensionName];
    if (conversationView) {
        return YES;
    }
    
    YapDatabaseViewGrouping *viewGrouping = [YapDatabaseViewGrouping withObjectBlock:^NSString *(NSString *collection, NSString *key, id object) {
        if ([object isKindOfClass:[OTRBuddy class]])
        {
            OTRBuddy *buddy = (OTRBuddy *)object;
            
            
            
            
            if (buddy.lastMessageDate || [self isGroupChat:buddy.username]) {
                
              
                
                return OTRConversationGroup;
            }
        }
        return nil; // exclude from view
    }];
    
    YapDatabaseViewSorting *viewSorting = [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2) {
        if ([group isEqualToString:OTRConversationGroup]) {
            if ([object1 isKindOfClass:[OTRBuddy class]] && [object2 isKindOfClass:[OTRBuddy class]]) {
                OTRBuddy *buddy1 = (OTRBuddy *)object1;
                OTRBuddy *buddy2 = (OTRBuddy *)object2;
                
                return [buddy2.lastMessageDate compare:buddy1.lastMessageDate];
            }
        }
        return NSOrderedSame;
    }];
    
    YapDatabaseViewOptions *options = [[YapDatabaseViewOptions alloc] init];
    options.isPersistent = YES;
    options.allowedCollections = [[YapWhitelistBlacklist alloc] initWithWhitelist:[NSSet setWithObject:[OTRBuddy collection]]];
    
    YapDatabaseView *databaseView = [[YapDatabaseView alloc] initWithGrouping:viewGrouping
                                                                      sorting:viewSorting
                                                                   versionTag:@"1"
                                                                      options:options];
    
    return [[OTRDatabaseManager sharedInstance].database registerExtension:databaseView withName:OTRConversationDatabaseViewExtensionName];
}




+ (BOOL)registerAllAccountsDatabaseView
{
    YapDatabaseView *accountView = [[OTRDatabaseManager sharedInstance].database registeredExtension:OTRAllAccountDatabaseViewExtensionName];
    if (accountView) {
        return YES;
    }
    
    YapDatabaseViewGrouping *viewGrouping = [YapDatabaseViewGrouping withKeyBlock:^NSString *(NSString *collection, NSString *key) {
        if ([collection isEqualToString:[OTRAccount collection]])
        {
            return OTRAllAccountGroup;
        }
        
        return nil;
    }];
    
    YapDatabaseViewSorting *viewSorting = [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2) {
        if ([group isEqualToString:OTRAllAccountGroup]) {
            if ([object1 isKindOfClass:[OTRAccount class]] && [object2 isKindOfClass:[OTRAccount class]]) {
                OTRAccount *account1 = (OTRAccount *)object1;
                OTRAccount *account2 = (OTRAccount *)object2;
                
                return [account1.displayName compare:account2.displayName options:NSCaseInsensitiveSearch];
            }
        }
        return NSOrderedSame;
    }];
    
    YapDatabaseViewOptions *options = [[YapDatabaseViewOptions alloc] init];
    options.isPersistent = YES;
    options.allowedCollections = [[YapWhitelistBlacklist alloc] initWithWhitelist:[NSSet setWithObject:[OTRAccount collection]]];
    
    YapDatabaseView *databaseView = [[YapDatabaseView alloc] initWithGrouping:viewGrouping
                                                                      sorting:viewSorting
                                                                   versionTag:@"1"
                                                                      options:options];
    
    return [[OTRDatabaseManager sharedInstance].database registerExtension:databaseView withName:OTRAllAccountDatabaseViewExtensionName];
}

+ (BOOL)registerChatDatabaseView
{
    if ([[OTRDatabaseManager sharedInstance].database registeredExtension:OTRChatDatabaseViewExtensionName]) {
        return YES;
    }
    
    YapDatabaseViewGrouping *viewGrouping = [YapDatabaseViewGrouping withObjectBlock:^NSString *(NSString *collection, NSString *key, id object) {
        if ([object isKindOfClass:[OTRMessage class]])
        {
            return ((OTRMessage *)object).buddyUniqueId;
        }
        return nil;
    }];
    
    YapDatabaseViewSorting *viewSorting = [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2) {
        if ([group isEqualToString:OTRChatMessageGroup]) {
            if ([object1 isKindOfClass:[OTRMessage class]] && [object2 isKindOfClass:[OTRMessage class]]) {
                OTRMessage *message1 = (OTRMessage *)object1;
                OTRMessage *message2 = (OTRMessage *)object2;
                
                return [message1.date compare:message2.date];
            }
        }
        return NSOrderedSame;
    }];
    
    YapDatabaseViewOptions *options = [[YapDatabaseViewOptions alloc] init];
    options.isPersistent = YES;
    options.allowedCollections = [[YapWhitelistBlacklist alloc] initWithWhitelist:[NSSet setWithObject:[OTRMessage collection]]];
    
    
    
    YapDatabaseView *view = [[YapDatabaseView alloc] initWithGrouping:viewGrouping
                                                              sorting:viewSorting
                                                           versionTag:@"1"
                                                              options:options];
    
    return [[OTRDatabaseManager sharedInstance].database registerExtension:view withName:OTRChatDatabaseViewExtensionName];
}

+ (BOOL)registerBuddyDatabaseView
{
    YapDatabaseViewGrouping *viewGrouping = [YapDatabaseViewGrouping withKeyBlock:^NSString *(NSString *collection, NSString *key) {
        return key;
    }];
    
    YapDatabaseViewSorting *viewSorting = [YapDatabaseViewSorting withKeyBlock:^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1, NSString *collection2, NSString *key2) {
        return NSOrderedSame;
    }];
    
    YapDatabaseViewOptions *options = [[YapDatabaseViewOptions alloc] init];
    options.isPersistent = YES;
    options.allowedCollections = [[YapWhitelistBlacklist alloc] initWithWhitelist:[NSSet setWithObject:[OTRBuddy collection]]];
    
    
    YapDatabaseView *view = [[[OTRDatabaseManager sharedInstance].database registeredExtensions] objectForKey:OTRBuddyDatabaseViewExtensionName];
    int version = 1;
    if (view){
        [[OTRDatabaseManager sharedInstance].database unregisterExtensionWithName:OTRBuddyDatabaseViewExtensionName];
        version = [view.versionTag intValue];
        version += 1;
    }
    
    view = [[YapDatabaseView alloc] initWithGrouping:viewGrouping
                                             sorting:viewSorting
                                          versionTag:[NSString stringWithFormat:@"%d",version]
                                             options:options];
    
    return [[OTRDatabaseManager sharedInstance].database registerExtension:view withName:OTRBuddyDatabaseViewExtensionName];
    
}

+ (BOOL)registerBuddyNameSearchDatabaseView
{
    if ([[OTRDatabaseManager sharedInstance].database registeredExtension:OTRBuddyNameSearchDatabaseViewExtensionName]) {
        return YES;
    }
    
    NSArray *propertiesToIndex = @[OTRBuddyAttributes.username,OTRBuddyAttributes.displayName];
    
    YapDatabaseFullTextSearchHandler *searchHandler = [YapDatabaseFullTextSearchHandler withObjectBlock:^(NSMutableDictionary *dict, NSString *collection, NSString *key, id object) {
        if ([object isKindOfClass:[OTRBuddy class]])
        {
            OTRBuddy *buddy = (OTRBuddy *)object;
            
            
  
            
            if([buddy.username length] && ![OTRDatabaseView isComposeCurAccount:buddy.username] && ![self isGroupChat:buddy.username]) {
                [dict setObject:buddy.username forKey:OTRBuddyAttributes.username];
            }
            
            if ([buddy.displayName length]) {
                [dict setObject:buddy.displayName forKey:OTRBuddyAttributes.displayName];
            }
            
            
        }
    }];
    
    YapDatabaseFullTextSearch *fullTextSearch = [[YapDatabaseFullTextSearch alloc] initWithColumnNames:propertiesToIndex handler:searchHandler];
    
    return [[OTRDatabaseManager sharedInstance].database registerExtension:fullTextSearch withName:OTRBuddyNameSearchDatabaseViewExtensionName];
}

+ (BOOL)registerAllBuddiesDatabaseView
{
    if ([[OTRDatabaseManager sharedInstance].database registeredExtension:OTRAllBuddiesDatabaseViewExtensionName]) {
        return YES;
    }
    
   
    
    
    YapDatabaseViewGrouping *viewGrouping = [YapDatabaseViewGrouping withObjectBlock:^NSString *(NSString *collection, NSString *key, id object) {
        if ([object isKindOfClass:[OTRBuddy class]]) {
            
            
            
             OTRBuddy *buddy = (OTRBuddy *)object;
            
            
             
            
            
            
            if([self isComposeCurAccount:buddy.username] || [self isGroupChat:buddy.username]) return nil; //zigzagcorp if
            
            return OTRBuddyGroup;
        }
        return nil;
    }];
    
    YapDatabaseViewSorting *viewSorting = [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2) {
        
        OTRBuddy *buddy1 = (OTRBuddy *)object1;
        OTRBuddy *buddy2 = (OTRBuddy *)object2;
        
        if (buddy1.status == buddy2.status) {
            NSString *buddy1String = buddy1.username;
            NSString *buddy2String = buddy2.username;
            
            if ([buddy1.displayName length]) {
                buddy1String = buddy1.displayName;
            }
            
            if ([buddy2.displayName length]) {
                buddy2String = buddy2.displayName;
            }
            
            return [buddy1String compare:buddy2String options:NSCaseInsensitiveSearch];
        }
        else if (buddy1.status < buddy2.status) {
            return NSOrderedAscending;
        }
        else{
            return NSOrderedDescending;
        }
    }];
    
    
    YapDatabaseViewOptions *options = [[YapDatabaseViewOptions alloc] init];
    options.isPersistent = YES;
    options.allowedCollections = [[YapWhitelistBlacklist alloc] initWithWhitelist:[NSSet setWithObject:[OTRBuddy collection]]];
    
    YapDatabaseView *view = [[YapDatabaseView alloc] initWithGrouping:viewGrouping
                                                              sorting:viewSorting
                                                           versionTag:@"1"
                                                              options:options];
    
    return [[OTRDatabaseManager sharedInstance].database registerExtension:view withName:OTRAllBuddiesDatabaseViewExtensionName];
    
}

+ (BOOL)registerAllSubscriptionRequestsView
{
    if ([[OTRDatabaseManager sharedInstance].database registeredExtension:OTRAllSubscriptionRequestsViewExtensionName]) {
        return YES;
    }
    
    YapDatabaseViewGrouping *viewGrouping = [YapDatabaseViewGrouping withKeyBlock:^NSString *(NSString *collection, NSString *key) {
        if ([collection isEqualToString:[OTRXMPPPresenceSubscriptionRequest collection]])
        {
            return OTRAllPresenceSubscriptionRequestGroup;
        }
        
        return nil;
    }];
    
    YapDatabaseViewSorting *viewSorting = [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2) {
        
        OTRXMPPPresenceSubscriptionRequest *request1 = (OTRXMPPPresenceSubscriptionRequest *)object1;
        OTRXMPPPresenceSubscriptionRequest *request2 = (OTRXMPPPresenceSubscriptionRequest *)object2;
        
        if (request1 && request2) {
            return [request1.date compare:request2.date];
        }
        
        return NSOrderedSame;
    }];
    
    YapDatabaseViewOptions *options = [[YapDatabaseViewOptions alloc] init];
    options.isPersistent = YES;
    options.allowedCollections = [[YapWhitelistBlacklist alloc] initWithWhitelist:[NSSet setWithObject:[OTRXMPPPresenceSubscriptionRequest collection]]];
    
    YapDatabaseView *databaseView = [[YapDatabaseView alloc] initWithGrouping:viewGrouping
                                                                      sorting:viewSorting
                                                                   versionTag:@"1"
                                                                      options:options];
    
    return [[OTRDatabaseManager sharedInstance].database registerExtension:databaseView withName:OTRAllSubscriptionRequestsViewExtensionName];
}

+ (BOOL)registerUnreadMessagesView
{
    
    YapDatabaseViewFiltering *viewFiltering = [YapDatabaseViewFiltering withObjectBlock:^BOOL(NSString *group, NSString *collection, NSString *key, id object) {
        
        if ([object isKindOfClass:[OTRMessage class]]) {
            return !((OTRMessage *)object).isRead;
        }
        return NO;
    }];
    
    YapDatabaseFilteredView *filteredView = [[YapDatabaseFilteredView alloc] initWithParentViewName:OTRChatDatabaseViewExtensionName
                                                                                          filtering:viewFiltering];
    
    
    return [[OTRDatabaseManager sharedInstance].database registerExtension:filteredView withName:OTRUnreadMessagesViewExtensionName];
}

+ (BOOL)registerPushView
{
    /*if ([[OTRDatabaseManager sharedInstance].database registeredExtension:OTRAllPushAccountInfoViewExtensionName]) {
     return YES;
     }*/
    
    [[OTRDatabaseManager sharedInstance].database unregisterExtensionWithName:OTRAllPushAccountInfoViewExtensionName];
    
    YapDatabaseViewGrouping *viewGrouping = [YapDatabaseViewGrouping withKeyBlock:^NSString *(NSString *collection, NSString *key) {
        
        if ([collection isEqualToString:[OTRYapPushAccount collection]])
        {
            return OTRPushAccountGroup;
        }
        else if ([collection isEqualToString:[OTRYapPushDevice collection]])
        {
            return OTRPushDeviceGroup;
        }
        else if ([collection isEqualToString:[OTRYapPushToken collection]])
        {
            return OTRPushTokenGroup;
        }
        
        return nil;
        
    }];
    
    YapDatabaseViewSorting *viewSorting = [YapDatabaseViewSorting withKeyBlock:^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1, NSString *collection2, NSString *key2) {
        return NSOrderedSame;
    }];
    
    YapDatabaseViewOptions *options = [[YapDatabaseViewOptions alloc] init];
    options.isPersistent = YES;
    options.allowedCollections = [[YapWhitelistBlacklist alloc] initWithWhitelist:[NSSet setWithArray:@[[OTRYapPushAccount collection],[OTRYapPushDevice collection],[OTRYapPushToken collection]]]];
    
    YapDatabaseView *databaseView = [[YapDatabaseView alloc] initWithGrouping:viewGrouping
                                                                      sorting:viewSorting
                                                                   versionTag:@"1" options:options];
    return [[OTRDatabaseManager sharedInstance].database registerExtension:databaseView withName:OTRAllPushAccountInfoViewExtensionName];
}

@end
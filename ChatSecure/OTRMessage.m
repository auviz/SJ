//
//  OTRMessage.m
//  Off the Record
//
//  Created by David Chiles on 3/28/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import "OTRMessage.h"
#import "OTRBuddy.h"
#import "OTRAccount.h"
#import "YapDatabaseTransaction.h"
#import "OTRDatabaseManager.h"
#import "YapDatabaseRelationshipTransaction.h"
#import "NSString+HTML.h"
#import "Strings.h"
#import "OTRConstants.h"
#import "YapDatabaseQuery.h"
#import "YapDatabaseSecondaryIndexTransaction.h"
#import "SetGlobVar.h"
#import "destroySecureMessage.h"
#import "OTRLog.h"

const struct OTRMessageAttributes OTRMessageAttributes = {
	.date = @"date",
	.text = @"text",
	.delivered = @"delivered",
	.read = @"read",
	.incoming = @"incoming",
    .messageId = @"messageId",
    .transportedSecurely = @"transportedSecurely"
};

const struct OTRMessageRelationships OTRMessageRelationships = {
	.buddyUniqueId = @"buddyUniqueId",
};

const struct OTRMessageEdges OTRMessageEdges = {
	.buddy = @"buddy",
};


@implementation OTRMessage

@synthesize media;

- (id)init
{
    if (self = [super init]) {
        self.date = [NSDate date];
        self.messageId = [[NSUUID UUID] UUIDString];
        self.delivered = NO;
        self.read = NO;
        
    }
    return self;
}

- (OTRBuddy *)buddyWithTransaction:(YapDatabaseReadTransaction *)readTransaction
{

    return [OTRBuddy fetchObjectWithUniqueID:self.buddyUniqueId transaction:readTransaction];
}

#pragma - mark YapDatabaseRelationshipNode

- (NSArray *)yapDatabaseRelationshipEdges
{
    NSArray *edges = nil;
    if (self.buddyUniqueId) {
        YapDatabaseRelationshipEdge *buddyEdge = [YapDatabaseRelationshipEdge edgeWithName:OTRMessageEdges.buddy
                                                                            destinationKey:self.buddyUniqueId
                                                                                collection:[OTRBuddy collection]
                                                                           nodeDeleteRules:YDB_DeleteSourceIfDestinationDeleted];
        
        edges = @[buddyEdge];
    }
    
    return edges;
    
}

#pragma - mark Class Methods

+ (NSInteger)numberOfUnreadMessagesWithTransaction:(YapDatabaseReadTransaction*)transaction
{
    __block int count = 0;
    [transaction enumerateKeysAndObjectsInCollection:[OTRMessage collection] usingBlock:^(NSString *key, OTRMessage *message, BOOL *stop) {
        if ([message isKindOfClass:[OTRMessage class]]) {
            if (!message.isRead) {
                
                count +=1;
            }
        }
    }];
    return count;
}


+ (NSInteger)countUnreadMessagesForBuddyId:(NSString *)uniqueBuddyId transaction:(YapDatabaseReadTransaction*)transaction
{
    __block int count = 0;
    [transaction enumerateKeysAndObjectsInCollection:[OTRMessage collection] usingBlock:^(NSString *key, OTRMessage *message, BOOL *stop) {
        if ([message isKindOfClass:[OTRMessage class]]) {
            if (!message.isRead && [message.buddyUniqueId isEqualToString:uniqueBuddyId]) {
                
                count +=1;
            }
        }
    }];
    
   
    return count;
}



+ (void)deleteAllMessagesWithTransaction:(YapDatabaseReadWriteTransaction*)transaction
{
    [transaction removeAllObjectsInCollection:[OTRMessage collection]];
}
//zigzagcorp info
+ (void)deleteAllMessagesForBuddyId:(NSString *)uniqueBuddyId transaction:(YapDatabaseReadWriteTransaction*)transaction
{
    [[transaction ext:OTRYapDatabaseRelationshipName] enumerateEdgesWithName:OTRMessageEdges.buddy destinationKey:uniqueBuddyId collection:[OTRBuddy collection] usingBlock:^(YapDatabaseRelationshipEdge *edge, BOOL *stop) {
        
        OTRMessage *message =  [transaction objectForKey:edge.sourceKey inCollection:edge.sourceCollection];
        
        NSString *photoUnicName = message.text ? message.text : message.unicPhotoName;
        
        if(photoUnicName){
            deletePhotosWithPreview(photoUnicName); //Удаляю фото из приложения
        }
        
        
        [transaction removeObjectForKey:edge.sourceKey inCollection:edge.sourceCollection];
        
        
        
    }];
    //Update Last message date for sorting and grouping
    OTRBuddy *buddy = [OTRBuddy fetchObjectWithUniqueID:uniqueBuddyId transaction:transaction];
    buddy.lastMessageDate = nil;
    [buddy saveWithTransaction:transaction];
}

+ (NSMutableArray *)getAllPhotosForBuddyId:(NSString *)uniqueBuddyId transaction:(YapDatabaseReadWriteTransaction*)transaction
{
     NSMutableArray *arrPhotos =[[NSMutableArray alloc] init];
    
    [[transaction ext:OTRYapDatabaseRelationshipName] enumerateEdgesWithName:OTRMessageEdges.buddy destinationKey:uniqueBuddyId collection:[OTRBuddy collection] usingBlock:^(YapDatabaseRelationshipEdge *edge, BOOL *stop) {
        //[transaction getObject:edge.sourceKey inCollection:edge.sourceCollection];
        OTRMessage *message =  [transaction objectForKey:edge.sourceKey inCollection:edge.sourceCollection];
        
        if(isMarkPhoto(message.unicPhotoName) || isMarkPhoto(message.text)){
              [arrPhotos addObject:message];
        }
    }];
    
    //DDLogInfo(@"Items %@", arrPhotos);
    
    return arrPhotos;

}

+ (void)deleteAllMessagesForAccountId:(NSString *)uniqueAccountId transaction:(YapDatabaseReadWriteTransaction*)transaction
{
    [[transaction ext:OTRYapDatabaseRelationshipName] enumerateEdgesWithName:OTRBuddyEdges.account destinationKey:uniqueAccountId collection:[OTRAccount collection] usingBlock:^(YapDatabaseRelationshipEdge *edge, BOOL *stop) {
        [self deleteAllMessagesForBuddyId:edge.sourceKey transaction:transaction];
    }];
}

+ (void)zigDeleteAllMessagesForAccountId:(NSString *)uniqueAccountId transaction:(YapDatabaseReadWriteTransaction*)transaction
{
    NSMutableArray *keys =[[NSMutableArray alloc] init];
    
    [[transaction ext:OTRYapDatabaseRelationshipName] enumerateEdgesWithName:OTRBuddyEdges.account destinationKey:uniqueAccountId collection:[OTRAccount collection] usingBlock:^(YapDatabaseRelationshipEdge *edge, BOOL *stop) {
        
       // OTRMessage *message = [[OTRMessage alloc] init];
      //  message.text = @"";
       // message.buddyUniqueId = edge.sourceKey;
       // message.incoming = YES;
        
        
        //keys;
     
        
        DDLogInfo(@"ID: %@, %@", edge.sourceKey, edge.name);
        
        [keys addObject:edge.sourceKey];
        
       // [self deleteAllMessagesForBuddyId:edge.sourceKey transaction:transaction];

       // [message saveWithTransaction:transaction];
        
        
    }];
    
    for(NSString *BuddyId in keys){
        [OTRMessage deleteAllMessagesForBuddyId:BuddyId transaction:transaction];

    }
    
    keys = nil;
    
 //[OTRMessage deleteAllMessagesForBuddyId:@"1AACC56F-12C4-43A7-9BE9-C30807C0ECEA" transaction:transaction];
    
    //[transaction removeObjectsForKeys:keys inCollection:collection];
}

+ (void)receivedDeliveryReceiptForMessageId:(NSString *)messageId transaction:(YapDatabaseReadWriteTransaction*)transaction
{
    [transaction enumerateKeysAndObjectsInCollection:[OTRMessage collection] usingBlock:^(NSString *key, id object, BOOL *stop) {
        if ([object isKindOfClass:[OTRMessage class]]) {
            OTRMessage *message = (OTRMessage *)object;
            if ([message.messageId isEqualToString:messageId]) {
                message.delivered = YES;
                [transaction setObject:message forKey:message.uniqueId inCollection:[OTRMessage collection]];
                
                *stop = YES;
            }
        }
    }];
}

+ (BOOL)isMessageInDBForMessageId:(NSString *)messageId transaction:(YapDatabaseReadWriteTransaction*)transaction
{
   __block BOOL isMessage = NO;
    
    [transaction enumerateKeysAndObjectsInCollection:[OTRMessage collection] usingBlock:^(NSString *key, id object, BOOL *stop) {
        if ([object isKindOfClass:[OTRMessage class]]) {
            OTRMessage *message = (OTRMessage *)object;
            if ([message.messageId isEqualToString:messageId]) {
             
              
                
                    isMessage = YES;
                
                *stop = YES;
            }
        }
    }];
    
    return isMessage;
}

+ (void)showLocalNotificationForMessage:(OTRMessage *)message
{
    if (![[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * rawMessage = [message.text stringByConvertingHTMLToPlainText];
            // We are not active, so use a local notification instead
            __block OTRBuddy *localBuddy = nil;
            __block OTRAccount *localAccount;
            __block NSInteger unreadCount = 0;
            [[OTRDatabaseManager sharedInstance].mainThreadReadOnlyDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
               
                localBuddy = [message buddyWithTransaction:transaction];
                localAccount = [localBuddy accountWithTransaction:transaction];
                unreadCount = [self numberOfUnreadMessagesWithTransaction:transaction];
            }];
            
            NSString *name = localBuddy.username;
            if ([localBuddy.displayName length]) {
                name = localBuddy.displayName;
            }
            
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = REPLY_STRING;
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.applicationIconBadgeNumber = unreadCount;
            localNotification.alertBody = [NSString stringWithFormat:@"%@: %@",name,rawMessage];
            
            localNotification.userInfo = @{kOTRNotificationBuddyUniqueIdKey:localBuddy.uniqueId};
        
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        });
    }
}

+ (void)enumerateMessagesWithMessageId:(NSString *)messageId transaction:(YapDatabaseReadTransaction *)transaction usingBlock:(void (^)(OTRMessage *message,BOOL *stop))block;
{
    if ([messageId length] && block) {
        NSString *queryString = [NSString stringWithFormat:@"Where %@ = ?",OTRYapDatabseMessageIdSecondaryIndex];
        YapDatabaseQuery *query = [YapDatabaseQuery queryWithFormat:queryString,messageId];
        
        [[transaction ext:OTRYapDatabseMessageIdSecondaryIndexExtension] enumerateKeysMatchingQuery:query usingBlock:^(NSString *collection, NSString *key, BOOL *stop) {
            OTRMessage *message = [OTRMessage fetchObjectWithUniqueID:key transaction:transaction];
            if (message) {
                block(message,stop);
            }
        }];
        
    }    
}




#pragma mark - DSM Messages

+ (void)deleteExpiredMessage:(YapDatabaseReadWriteTransaction*)transaction
{
 
    
    __block NSMutableArray *expMessages=nil;
    
    [transaction enumerateKeysAndObjectsInCollection:[OTRMessage collection] usingBlock:^(NSString *key, OTRMessage *message, BOOL *stop) {
        if ([message isKindOfClass:[OTRMessage class]]) {
            if ([destroySecureMessage isExpiredMessage:message.securExperiedTime] && message.securExperiedTime) {
              
                if(!expMessages){
                    expMessages = [[NSMutableArray alloc] init];
                }
                
                [expMessages addObject:message];
                
              //  NSLog(@"message LOOOOG %@", message);
            //   [message removeWithTransaction:transaction];
            }
        }
    }];
    
    
    if(expMessages){
        
        for (OTRMessage* message in expMessages) {
          
        
        [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [message removeWithTransaction:transaction];
            deletePhotosWithPreview(message.unicPhotoName);
            
            
            //ZIGPOINT
        
        } completionBlock:^{
          [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NEED_RELOAD_COLLECTION object:self];
        
        }];
            
         }
        
    }
    
}

+ (void)receivedIReadExpiredMessageForMessageId:(NSString *)messageId experiedDate:(NSDate *)expDate transaction:(YapDatabaseReadWriteTransaction*)transaction
{
    [transaction enumerateKeysAndObjectsInCollection:[OTRMessage collection] usingBlock:^(NSString *key, id object, BOOL *stop) {
        if ([object isKindOfClass:[OTRMessage class]]) {
            OTRMessage *message = (OTRMessage *)object;
            if ([message.messageId isEqualToString:messageId]) {
                
                message.delivered = YES;
                message.securExperiedTime = expDate;
                
                [transaction setObject:message forKey:message.uniqueId inCollection:[OTRMessage collection]];
                
                *stop = YES;
            }
        }
    }];
}

+(OTRMessage *)OTRMessageByMessageId:(NSString *)messageId{
    
    __block OTRMessage *messageTemp;
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        [transaction enumerateKeysAndObjectsInCollection:[OTRMessage collection] usingBlock:^(NSString *key, id object, BOOL *stop) {
            if ([object isKindOfClass:[OTRMessage class]]) {
                OTRMessage *message = (OTRMessage *)object;
                if ([message.messageId isEqualToString:messageId]) {
                    *stop = YES;
                      messageTemp = message;
                    
                }
            }
        }];
    }];
    
    return messageTemp;
    
}

@end

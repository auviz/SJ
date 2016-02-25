//
//  OTRMessage.h
//  Off the Record
//
//  Created by David Chiles on 3/28/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import "OTRYapDatabaseObject.h"
#import "JSQMessageMediaData.h"

@class OTRBuddy,YapDatabaseReadTransaction;

extern const struct OTRMessageAttributes {
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *text;
	//__unsafe_unretained NSString *senderDisplayName;
	__unsafe_unretained NSString *delivered;
	__unsafe_unretained NSString *read;
	__unsafe_unretained NSString *incoming;
    __unsafe_unretained NSString *messageId;
    __unsafe_unretained NSString *transportedSecurely;
    __unsafe_unretained NSString *groupChatUserJid;
    
} OTRMessageAttributes;

extern const struct OTRMessageRelationships {
	__unsafe_unretained NSString *buddyUniqueId;
} OTRMessageRelationships;

extern const struct OTRMessageEdges {
	__unsafe_unretained NSString *buddy;
} OTRMessageEdges;

@interface OTRMessage : OTRYapDatabaseObject <YapDatabaseRelationshipNode>

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *text;
//@property (nonatomic, strong) NSString *senderDisplayName;

@property (nonatomic, strong) id<JSQMessageMediaData> media;
@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, getter = isDelivered) BOOL delivered;
@property (nonatomic, getter = isRead) BOOL read;
@property (nonatomic, getter = isIncoming) BOOL incoming;
@property (nonatomic, getter = isTransportedSecurely) BOOL transportedSecurely;

@property (nonatomic, strong) NSString *unicPhotoName; // zigzagcorp prop
@property (nonatomic, strong) NSString *unicLocationName;

@property (nonatomic, strong) NSString *groupChatUserJid;

@property (nonatomic, strong) NSString *buddyUniqueId;

@property (nonatomic, strong) NSString *securBody;
@property (nonatomic, strong) NSString *lifeTime;
@property (nonatomic, strong) NSDate * securExperiedTime;
@property (nonatomic, strong) NSArray * sendCanceledForUsers;
@property (nonatomic, strong) NSArray * participants;



- (OTRBuddy *)buddyWithTransaction:(YapDatabaseReadTransaction *)readTransaction;


+ (NSInteger)numberOfUnreadMessagesWithTransaction:(YapDatabaseReadTransaction*)transaction;
+ (NSInteger)countUnreadMessagesForBuddyId:(NSString *)uniqueBuddyId transaction:(YapDatabaseReadTransaction*)transaction;
+ (void)deleteAllMessagesWithTransaction:(YapDatabaseReadWriteTransaction*)transaction;
+ (void)deleteAllMessagesForBuddyId:(NSString *)uniqueBuddyId transaction:(YapDatabaseReadWriteTransaction*)transaction;
+ (void)deleteAllMessagesForAccountId:(NSString *)uniqueAccountId transaction:(YapDatabaseReadWriteTransaction*)transaction;
+ (void)zigDeleteAllMessagesForAccountId:(NSString *)uniqueAccountId transaction:(YapDatabaseReadWriteTransaction*)transaction;
+ (void)receivedDeliveryReceiptForMessageId:(NSString *)messageId transaction:(YapDatabaseReadWriteTransaction*)transaction;

+ (BOOL)isMessageInDBForMessageId:(NSString *)messageId transaction:(YapDatabaseReadWriteTransaction*)transaction;

+ (NSMutableArray *)getAllPhotosForBuddyId:(NSString *)uniqueBuddyId transaction:(YapDatabaseReadWriteTransaction*)transaction;

+ (void)showLocalNotificationForMessage:(OTRMessage *)message;

+ (void)enumerateMessagesWithMessageId:(NSString *)messageId transaction:(YapDatabaseReadTransaction *)transaction usingBlock:(void (^)(OTRMessage *message,BOOL *stop))block;

+(OTRMessage *)OTRMessageByMessageId:(NSString *)messageId;

//Secur Messages
+ (void)deleteExpiredMessage:(YapDatabaseReadWriteTransaction*)transaction;

+ (void)receivedIReadExpiredMessageForMessageId:(NSString *)messageId experiedDate:(NSDate *)expDate transaction:(YapDatabaseReadWriteTransaction*)transaction;




@end

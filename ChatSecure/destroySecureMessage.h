//
//  destroySecureMessage.h
//  SafeJab
//
//  Created by Самсонов Александр on 10.11.15.
//  Copyright © 2015 Leader Consult. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTRMessage.h"
#import "OTRMessagesViewController.h"
//@class OTRMessagesViewController;

@interface destroySecureMessage : NSObject


@property (nonatomic, strong) OTRMessage * message;

@property (nonatomic, strong) dispatch_queue_t myQueue;

@property (nonatomic, strong) NSTimer * timerLifeTime;

@property (nonatomic, strong) UILabel * timerLabelForMessage;

@property  (nonatomic) int secondsBeforeDelMes;

-(void)setExpireMessageIncoming;

+(destroySecureMessage *)addMessageToShared:(OTRMessage *)mes;

+(destroySecureMessage *)getDSMessageById:(NSString *)messageId;

+(void)deleteDSMessageById:(NSString *)messageId;

+(void)deleteAllSharedMessagesFromDic;

+(void)setViewController:(OTRMessagesViewController *)mvc;

+(BOOL)isExpiredMessage:(NSDate *)securExperiedTime;

-(void)clearTimerLifeTime;

@end

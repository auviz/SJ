//
//  destroySecureMessage.m
//  SafeJab
//
//  Created by Самсонов Александр on 10.11.15.
//  Copyright © 2015 Leader Consult. All rights reserved.
//

#import "destroySecureMessage.h"
#import "Strings.h"
#import "OTRDatabaseManager.h"
#import "OTRBuddy.h"
#import "OTRXMPPManager.h"
#import "SetGlobVar.h"

@implementation destroySecureMessage

static NSMutableDictionary *dicDSMessages_;
static OTRMessagesViewController *MVC_;

@synthesize message;


-(id)initWithOtrMessage:(OTRMessage *)mes{
    
 //   if(mes.securBody.length == 0 || !mes.securExperiedTime) return nil; //Ну чтоб не плодить экземпляры
    
    self = [super init];
    
    if(self){
        self.message = mes;
        [self setupMessage];
        
        return self;
    }
    
    return nil;
}


-(dispatch_queue_t)getMyQueue {
    
    if(!self.myQueue ) {
        self.myQueue =  dispatch_queue_create("destroy.queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self.myQueue;
    
    
}

-(void)setupSecondsBeforeDelMes{
    
    NSDate *now = [NSDate date];
    
    int timeNow =  [now timeIntervalSinceReferenceDate];
    
    int timeTo =  [self.message.securExperiedTime timeIntervalSinceReferenceDate];
    
    
    self.secondsBeforeDelMes = (timeTo - timeNow);
    
    
}


-(void)setupTimeLabelForMessage{
   
    if(!self.timerLabelForMessage){
        
        self.timerLabelForMessage = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 60, 20)];
        self.timerLabelForMessage.font = [UIFont systemFontOfSize:8];
        self.timerLabelForMessage.textColor = [UIColor redColor];
        self.timerLabelForMessage.text = [self convertTimeFromSeconds:self.secondsBeforeDelMes];
        
      
    }
  
    
}


-(void)setExpireMessageIncoming{
    
    
    if(!self.message.securExperiedTime){
    
    NSDate *now = [NSDate date];
    NSTimeInterval lifeTime = [self.message.lifeTime intValue];
    NSDate *securExperiedTime = [NSDate dateWithTimeInterval:+lifeTime
                                       sinceDate:now];
    
    
        self.message.securExperiedTime = securExperiedTime;
        //self.message.lifeTime = nil;
        self.message.text = self.message.securBody;
        self.message.securBody = nil;
        self.message.read = YES;
       
        
      
 
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [self.message saveWithTransaction:transaction];
    } completionBlock:^{
   
        
        [self actionsBeforeShow];
        [self sendIReadSecurMessage];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //Добавляем отображение таймера
            [MVC_ reloadDataForCollectionView];
        });
       
        
    }];
  
  
}
      
}

-(void)actionsBeforeShow{
    //Небходимые действия для появления таимера у сообщения
    [self setupSecondsBeforeDelMes];
    [self setTimerLifeTime];
    [self setupTimeLabelForMessage];
    
    

    
}

-(void)setupMessage{
    if(self.message.isIncoming && !self.message.securExperiedTime){
        message.text = [NSString stringWithFormat:@"🔒%@", TAP_TO_OPEN];
    }
}


- (NSString *)convertTimeFromSeconds:(int)seconds {
    
    // Return variable.
    NSString *result = @"";
    
    // Int variables for calculation.
    int secs = seconds;
    int tempDay     = 0;
    int tempHour    = 0;
    int tempMinute  = 0;
    int tempSecond  = 0;
    
    NSString *day       = @"";
    NSString *hour      = @"";
    NSString *minute    = @"";
    NSString *second    = @"";
    
    // Convert the seconds to hours, minutes and seconds.
    tempDay     = secs / 86400;
    tempHour    = secs / 3600 - tempDay * 24;
    tempMinute  = secs / 60 - (tempHour * 60 + tempDay * 24 * 60);
    tempSecond  = secs - (tempHour * 3600 + tempMinute * 60 + tempDay * 24 * 60 * 60);
    
    day    = [[NSNumber numberWithInt:tempDay] stringValue];
    hour    = [[NSNumber numberWithInt:tempHour] stringValue];
    minute  = [[NSNumber numberWithInt:tempMinute] stringValue];
    second  = [[NSNumber numberWithInt:tempSecond] stringValue];
    
    // Make time look like 00:00:00 and not 0:0:0
    if (tempHour < 10) {
        hour = [@"0" stringByAppendingString:hour];
    }
    
    if (tempMinute < 10) {
        minute = [@"0" stringByAppendingString:minute];
    }
    
    if (tempSecond < 10) {
        second = [@"0" stringByAppendingString:second];
    }
    
    if (tempHour == 0) {
        
        //NSLog(@"Result of Time Conversion: %@:%@", minute, second);
        result = [NSString stringWithFormat:@"%@:%@", minute, second];
        
    } else if ( tempDay ==0 ){
        
        //NSLog(@"Result of Time Conversion: %@:%@:%@", hour, minute, second);
        result = [NSString stringWithFormat:@"%@:%@:%@",hour, minute, second];
        
    } else {
       // NSLog(@"Result of DAY Conversion: %@ %@:%@:%@", day, hour, minute, second);
        result = [NSString stringWithFormat:@"%@d %@:%@:%@",day, hour, minute, second];
    }
    
    return result;
    
}

-(void)sendIReadSecurMessage{
    
    __block OTRBuddy *buddy = nil;
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        buddy = [self.message buddyWithTransaction:transaction];
    } completionBlock:^{
        
        if(!SafeJabTypeIsEqual(buddy.username, MUC_JABBER_HOST)){
            //Отключаю сообщение о прочтении  для груп чата пока пока
            [MVC_.xmppManager sendIOpenSecurMessage:self.message buddyJID:buddy.username];
        }
      
        
    }];
   
}

#pragma mark - Timer

-(void)setTimerLifeTime{
    
    if(!self.timerLifeTime){
    
    self.timerLifeTime = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                                   target: self
                                                                 selector: @selector(actionTimerLifeTime)
                                                                 userInfo: nil
                                                                  repeats: YES];
    }
}

-(void)clearTimerLifeTime{
    [self.timerLifeTime invalidate];
    self.timerLifeTime = nil;
}


-(void)actionTimerLifeTime{
   
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
    
    if(self.secondsBeforeDelMes <= 0){
        
       // [MVC_ deleteMessage:self.message]; //Удаление сообщения
        [destroySecureMessage deleteDSMessageById:self.message.messageId];
        self.timerLabelForMessage = nil;
    } else {
      
        self.secondsBeforeDelMes =  (self.secondsBeforeDelMes - 1) ;
        
       // NSLog(@"actionTimerLifeTime %d", (int)self.secondsBeforeDelMes);
        
        self.timerLabelForMessage.text = [self convertTimeFromSeconds:self.secondsBeforeDelMes];
    }
    });
}


#pragma mark - Static

+(void)setViewController:(OTRMessagesViewController *)mvc{
    MVC_ = mvc;
}

+(destroySecureMessage *)addMessageToShared:(OTRMessage *)mes
{
      destroySecureMessage *DSMes = nil;
    
    if(!mes.isIncoming) return nil; //Отключил добавление исходящих в словарь
    
    
    if(!dicDSMessages_){
        
        dicDSMessages_ = [[NSMutableDictionary alloc] init];
    }
    
    
    if(mes.securExperiedTime){
        
       
        //Если уже таймер пошел запустить его
        
        DSMes =  [self getDSMessageById:mes.messageId];
        
        if(!DSMes){
            DSMes = [[destroySecureMessage alloc] initWithOtrMessage:mes];
            [dicDSMessages_ setObject:DSMes forKey:mes.messageId];
        } else {
            return DSMes;
        }
        
        [DSMes actionsBeforeShow];
      
        
        return DSMes;
  
    } else if(mes.securBody.length > 0){
    //Если сообщение только пришло и мы его пока не открыли
     DSMes =  [self getDSMessageById:mes.messageId];
    

            if(!DSMes){
                  DSMes = [[destroySecureMessage alloc] initWithOtrMessage:mes];
                  [dicDSMessages_ setObject:DSMes forKey:mes.messageId];
            }
            return DSMes;
        
    } else {
        //Если это обычное сообщение
        return nil;
    }
    
}

+(void)deleteDSMessageById:(NSString *)messageId{
   
    if(!dicDSMessages_) return ;
    
    destroySecureMessage * DSM = [dicDSMessages_ objectForKey:messageId] ;
    
    if(DSM){
    [DSM clearTimerLifeTime]; //Останавливаю таймер
    [DSM.timerLabelForMessage removeFromSuperview]; //Удаляю таймер
    
    //[dicDSMessages_ removeObjectForKey:messageId];
    }
}

+(destroySecureMessage *)getDSMessageById:(NSString *)messageId{
    
    if(!dicDSMessages_ || messageId.length == 0) return nil;
    
    destroySecureMessage *DSM =  [dicDSMessages_ objectForKey:messageId];

    return DSM;
}


+(void)deleteAllSharedMessagesFromDic{
    
    MVC_ = nil;
    
    if(!dicDSMessages_) return;
    
    
    
    for(NSString *messageId in [dicDSMessages_ allKeys]){
        
        
        [self deleteDSMessageById:messageId];
        
        
    }
    
    [dicDSMessages_ removeAllObjects];
}

+(BOOL)isExpiredMessage:(NSDate *)securExperiedTime{
    NSDate *now = [NSDate date];
    
    int timeNow =  [now timeIntervalSinceReferenceDate];
    
    int timeTo =  [securExperiedTime timeIntervalSinceReferenceDate];
    
    if((timeTo - timeNow) > 0 ){
        return NO;
    } else {
        return YES;
    }
}


@end

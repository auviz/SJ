//
//  historyManager.m
//  SafeJab
//
//  Created by Самсонов Александр on 13.04.16.
//  Copyright © 2016 Leader Consult. All rights reserved.
//

#import "historyManager.h"
#import "SetGlobVar.h"
#import "dbHistoryOption.h"
#import "OTRMessage.h"
#import "OTRDatabaseManager.h"
#import "OTRBuddy.h"
#import "XMPPDateTimeProfiles.h"
#import "OTRXMPPBuddy.h"

@implementation historyManager

-(void)getHistoryOptionFromServer {
    NSString * user = SJAccount().username;
    
    if(!user) return;
    
    NSString *post =  [NSString stringWithFormat:@"nameOption=history&user=%@&type=get", user];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSString * url = [NSString stringWithFormat:@"https://%@/settingsManager.php", JABBER_HOST];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
    
    
    
    
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         
         if (error == nil && data)
         {
            
            NSString *option = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             //Сохраняю сколько хранить историю
             [dbHistoryOption set:option];
             
             if([option integerValue] > 0){
                 //Получаю архив сообщений
                 [self getArhiveFromSerever];
             }
             
           [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DID_HISTORY_OPTION_ON_SERVER object:self userInfo:@{@"key":option}];
             
         }
         
     }];
}



-(void)setHistoryOptionOnServer: (NSString *)value {
    
    //nameOption
    
    NSString * user = SJAccount().username;
    
    if(!user) return;
    
    NSString *post =  [NSString stringWithFormat:@"nameOption=history&user=%@&value=%@", user, value];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSString * url = [NSString stringWithFormat:@"https://%@/settingsManager.php", JABBER_HOST];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
    
    
    
    
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         
         if (error == nil)
         {
       
             //Сохраняю сколько хранить историю
             [dbHistoryOption set:value];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DID_HISTORY_OPTION_ON_SERVER object:self userInfo:@{@"key":value}];
             
             
         } else if (error != nil){
             NSLog(@"ErrorSetHistoryOption");
       [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ERROR_SET_HISTORY_OPTION_ON_SERVER  object:self userInfo:@{@"key":@"Error"}];
         }
         
     }];
    
    //[room changeRoomSubject:newRoomName];
    
}

-(void)getArhiveFromSerever {
    
    
    NSString * user = SJAccount().username;
    
    if(!user) return;
    
    NSString *post =  [NSString stringWithFormat:@"historyFor=%@", user];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSString * url = [NSString stringWithFormat:@"https://%@/historyManager/getHistoryManager.php", JABBER_HOST];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
    
    
    
    
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         
         if (error == nil && data)
         {
             
             
             NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
             
             
             for(NSDictionary * row in jsonObject){
                 
                 [self saveOtrMessageFromDict:row];
                 
                // NSLog(@"body_%@", [row objectForKey:@"body"]);
                 
             }
             
             
             
             
             //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DID_HISTORY_OPTION_ON_SERVER object:self userInfo:@{@"key":value}];
             
             
         } else if (error != nil){
            
           //  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ERROR_SET_HISTORY_OPTION_ON_SERVER  object:self userInfo:@{@"key":@"Error"}];
         }
         
     }];
    
}

#pragma mark - OTRMessage

-(void)saveGroupMessageFromDict:(NSDictionary *)row{
    
    
    NSString * buddyUser = [NSString stringWithFormat:@"%@@%@",[row objectForKey:@"to"], MUC_JABBER_HOST];
    
    
    __block OTRBuddy * groupBuddy =nil;
    [[OTRDatabaseManager sharedInstance].mainThreadReadOnlyDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        groupBuddy = [OTRBuddy fetchBuddyWithUsername:buddyUser withAccountUniqueId:SJAccount().uniqueId transaction:transaction];
    }];
    
    if(!groupBuddy) return ; //Если нет в списке контактов проигнорировать
    
    OTRMessage * message = [[OTRMessage alloc] init];
    
    message.buddyUniqueId = groupBuddy.uniqueId;
    message.text = base64StrToString([row objectForKey:@"body"]);
    message.messageId = [row objectForKey:@"messageId"];
    message.date = [XMPPDateTimeProfiles parseDateTime:[row objectForKey:@"time"]];
    
    BOOL isDelivered = [[row objectForKey:@"isDelivered"] isEqualToString:@"YES"];
    
    message.delivered = isDelivered;
    
  
    
    NSString * from = [NSString stringWithFormat:@"%@@%@",[row objectForKey:@"from"], JABBER_HOST];;
    
    message.groupChatUserJid = from;
    
    
    if([from isEqualToString:SJAccount().username]){
       message.incoming = NO;
    } else {
       message.incoming = YES;
    }
    
    
    message.read = [[row objectForKey:@"isReadGroupMessage"] isEqualToString:@"YES"];
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [message saveWithTransaction:transaction];
        
        
        //Важная херня для сортировки и обновления в списке активных чатов
        
        //Важная херня для сортировки и обновления в списке активных чатов
        if(message.incoming){
        groupBuddy.lastMessageDate = message.date;
        [groupBuddy saveWithTransaction:transaction];
        }
    }];
    
   
    
}

-(void)saveOtrMessageFromDict:(NSDictionary *)row{
    
    if(!row) return;
    
    //Если сообщение в базе то взять его и перезаписать в базе телефона (необходимо для правильной сортировки)
    if([OTRMessage isOTRMessageForKey:[row objectForKey:@"messageId"]]) {
    
        OTRMessage * messageFromDb = [OTRMessage OTRMessageByMessageId:[row objectForKey:@"messageId"]];
        
        if(messageFromDb.read || messageFromDb.isSorted) return; //Если сообщение уже прочитали не трогать (такие сообщения не нарушают сортировку)
        
        [OTRMessage deleteOTRMessageForMessageId:[row objectForKey:@"messageId"]];
        
        [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [messageFromDb saveWithTransaction:transaction];
            
         
            
        //    NSLog(@"EEE_%@", buddy.username);
            
            //Важная херня для сортировки и обновления в списке активных чатов
            if(messageFromDb.incoming){
                
                OTRBuddy * buddy = [transaction objectForKey:messageFromDb.buddyUniqueId inCollection:[OTRBuddy collection]];
                
                messageFromDb.isSorted = YES;
                
                buddy.lastMessageDate = messageFromDb.date;
                [buddy saveWithTransaction:transaction];
            }
           
        }];
        
    
    } else if ([[row objectForKey:@"isGroupChat"] isEqualToString:@"YES"]){
        
        //Если сохранили групповое сообщение остановится
        [self saveGroupMessageFromDict:row];
   
    } else {
        
   //Сохранение обычных сообщений
    OTRMessage * message = [[OTRMessage alloc] init];

 NSString *  buddyUser = [NSString stringWithFormat:@"%@@%@",[row objectForKey:@"from"], JABBER_HOST];
    message.incoming = YES;
    
    if([buddyUser isEqualToString:SJAccount().username]){
        buddyUser = [NSString stringWithFormat:@"%@@%@", [row objectForKey:@"to"], JABBER_HOST];
        message.incoming = NO;
    }
    
    
    __block OTRBuddy * buddy =nil;
    [[OTRDatabaseManager sharedInstance].mainThreadReadOnlyDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        buddy = [OTRBuddy fetchBuddyWithUsername:buddyUser withAccountUniqueId:SJAccount().uniqueId transaction:transaction];
    }];
        
        if(!buddy) return; //Если нет приятеля в спмске проигнорировать

      //id	to	from	body	messageId	lifeTime	time	historyFor isDelivered (YES NO) isReadGroupMessage isGroupChat
    
   
    message.buddyUniqueId = buddy.uniqueId;
    message.text = base64StrToString([row objectForKey:@"body"]);
    message.messageId = [row objectForKey:@"messageId"];
    message.date = [XMPPDateTimeProfiles parseDateTime:[row objectForKey:@"time"]];
    
   BOOL isDelivered = [[row objectForKey:@"isDelivered"] isEqualToString:@"YES"];
  

    
  //  NSLog(@"DeliveredXXX_%d", message.delivered);
    
    message.delivered = NO;
    
    if (!message.incoming){
        message.delivered = isDelivered;
    }
    
    
    if(isDelivered && message.incoming){
        
         message.read = YES;
    } else if (!message.incoming){
        message.read = YES;
    } else {
        message.read = NO;
    }
    
    
    
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [message saveWithTransaction:transaction];
        
        //Важная херня для сортировки и обновления в списке активных чатов
        if(message.incoming){
        buddy.lastMessageDate = message.date;
        [buddy saveWithTransaction:transaction];
        }
    }];
        
    }
}
#pragma mark - Delete messages from history

+(void)deleteAllMessagesForUser:(NSString *)user{
    
    
    NSString * post = [NSString stringWithFormat:@"option=all&historyFor=%@", user];
    
    [NSURLConnection
     sendAsynchronousRequest:[self genRequest:post]
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         
         if (error){
             
             [self sendNotificationWithError:@{@"key":@"Error"}];
         }
         
     }];
    
}


+(void)deleteAllMessagesForUser:(NSString *)user withBuddy:(NSString *)buddy{
    
    
    NSString * post = [NSString stringWithFormat:@"option=buddy&historyFor=%@&buddy=%@", user, buddy];
    
    [NSURLConnection
     sendAsynchronousRequest:[self genRequest:post]
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         
         if (error){
             
             [self sendNotificationWithError:@{@"key":@"Error"}];
         }
         
     }];
    
}


+(void)deleteMessageForUser:(NSString *)user withMessageId:(NSString *)messageId{
    
    
    NSString * post = [NSString stringWithFormat:@"option=one&historyFor=%@&messageId=%@", user, messageId];
    
    [NSURLConnection
     sendAsynchronousRequest:[self genRequest:post]
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         
         if (error){
             
             [self sendNotificationWithError:@{@"key":@"Error"}];
         }
         
     }];
    
}

+(void)sendNotificationWithError:(NSDictionary *)error{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ERROR_FOR_ALL_WITH_DICT  object:self userInfo:error];
}

+(NSMutableURLRequest *)genRequest:(NSString *)post{
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
     NSString * url = [NSString stringWithFormat:@"https://%@/historyManager/deleteMessagesFromHistory.php", JABBER_HOST];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    return request;
}

@end

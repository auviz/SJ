//
//  MUCArhive.m
//  SafeJab
//
//  Created by Самсонов Александр on 11.12.15.
//  Copyright © 2015 Leader Consult. All rights reserved.
//

#import "MUCArhive.h"
#import "SetGlobVar.h"
#import "OTRXMPPManager.h"
#import "OTRProtocolManager.h"
#import "OTRDatabaseManager.h"
#import "OTRMessage.h"

@implementation MUCArhive


+(NSMutableURLRequest *)genRequest:(NSString *)post{
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:@"https://safejab.com/groupChat/mucArchive.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    return request;
}

+(void)saveRoomMessage:(NSString*)RoomId message:(XMPPMessage *)message from:(NSString *)from {
    
    
    NSString *post =  [NSString stringWithFormat:@"option=newMessage&idRoom=%@&message=%@&messageFrom=%@&messageID=%@", RoomId, message, from, message.elementID];
    
    
    [NSURLConnection
     sendAsynchronousRequest:[self genRequest:post]
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         
         if ([data length] >0 && error == nil)
         {
      
             // DO YOUR WORK HERE
             
         }
         else if ([data length] == 0 && error == nil)
         {
             
             //  NSLog(@"Nothing was downloaded.");
         }
         else if (error != nil){
             
             //Ну ставлю статус не доставлено если соединение разорвано
             
             if ([message.elementID length]) {
                 
                 [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                     
                     [OTRMessage enumerateMessagesWithMessageId:message.elementID transaction:transaction usingBlock:^(OTRMessage *message, BOOL *stop) {
                         message.error = [[NSError alloc] initWithDomain:@"safejab.com" code:200 userInfo:
                                                               @{NSLocalizedDescriptionKey:@"Connection lost..."}];;
                         [message saveWithTransaction:transaction];
                         *stop = YES;
                     }];
                     
                     
                 }];
                    }
             
           //  DDLogInfo(@"Error = %@", error);
         }
         
     }];
    
    //[room changeRoomSubject:newRoomName];
    
}

+(void)getRoomMessages:(NSString *)roomID toAccount:(NSString *)toAccount{
    
    
    //Ждем запрос и не делаем других пока не завершится
    if(!MUCArhiveWaitForResponse_) MUCArhiveWaitForResponse_ = [[NSMutableDictionary alloc] init];
    if([[MUCArhiveWaitForResponse_ objectForKey:roomID] isEqualToString:@"YES"]) return; //Если запрос уже произошел подождать его
    [MUCArhiveWaitForResponse_ setObject:@"YES" forKey:roomID];
    
    NSString *post =  [NSString stringWithFormat:@"option=getMessages&idRoom=%@&toAccount=%@", roomID, toAccount];
    
    [NSURLConnection
     sendAsynchronousRequest:[self genRequest:post]
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         
         if ([data length] >0 && error == nil)
         {
             
             
              NSString *messages = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             
             NSArray * arrMessages =[messages componentsSeparatedByString:MUC_MESSAGES_SEPARATOR];
             
                    OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:SJAccount()];
           
             for(NSString *message in arrMessages){
                
                 [xmppManager receiveMessageForRoom:message];
             }
             
             //Тут я отсылаю сообщение о том что я прочитал сообщения
             [self sendGroupMessagesWereReadByRoomId:roomID account:toAccount];
             
           
             
             
             // DO YOUR WORK HERE
             
         }
         else if ([data length] == 0 && error == nil)
         {
            [MUCArhiveWaitForResponse_ removeObjectForKey:roomID];
             //  NSLog(@"Nothing was downloaded.");
         }
         else if (error != nil){
             [MUCArhiveWaitForResponse_ removeObjectForKey:roomID];
             // MUCArhiveWaitForResponse_ = NO;
             //  DDLogInfo(@"Error = %@", error);
         }
         
         [MUCArhiveWaitForResponse_ removeObjectForKey:roomID];
         
       
         
     }];
    
}


+(void)sendGroupMessagesWereReadByRoomId:(NSString *)roomID account:(NSString *)account {
  
        
        NSString *post =  [NSString stringWithFormat:@"option=theyWereRead&idRoom=%@&account=%@", roomID, account];
        
        [NSURLConnection
         sendAsynchronousRequest:[self genRequest:post]
         queue:[[NSOperationQueue alloc] init]
         completionHandler:^(NSURLResponse *response,
                             NSData *data,
                             NSError *error)
         {
            [MUCArhiveWaitForResponse_ removeObjectForKey:roomID];
             
           //  if ([data length] >0 && error == nil)
           //  {
                 /*
                 
                 NSString *messages = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                 
                 NSArray * arrMessages =[messages componentsSeparatedByString:MUC_MESSAGES_SEPARATOR];
                 
                 OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:SJAccount()];
                 
                 for(NSString *message in arrMessages){
                     
                     [xmppManager receiveMessageForRoom:message];
                 }
                 
               */
                 
                 
                 // DO YOUR WORK HERE
                 
           //  }
          //   else if ([data length] == 0 && error == nil)
            // {
                 //  NSLog(@"Nothing was downloaded.");
            // }
           //  else if (error != nil){
                 //  DDLogInfo(@"Error = %@", error);
            // }
             
         }];
        
    
}


+(NSString *)timeStamp{
    NSDate* datetime = [[NSDate alloc] init];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]]; // Prevent adjustment to user's local time zone.
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:SS'Z'"];
    return [dateFormatter stringFromDate:datetime];
}

@end

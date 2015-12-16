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

+(void)saveRoomMessage:(NSString*)RoomId message:(XMPPMessage *)message from:(NSString *)from {
    
    
    NSString *post =  [NSString stringWithFormat:@"option=newMessage&idRoom=%@&message=%@&messageFrom=%@", RoomId, message, from];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:@"https://safejab.com/groupChat/mucArchive.php"]];
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
    
    NSString *post =  [NSString stringWithFormat:@"option=getMessages&idRoom=%@&toAccount=%@", roomID, toAccount];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:@"https://safejab.com/groupChat/mucArchive.php"]];
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
         
         if ([data length] >0 && error == nil)
         {
             
              NSString *messages = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             
             NSArray * arrMessages =[messages componentsSeparatedByString:MUC_MESSAGES_SEPARATOR];
             
                    OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:SJAccount()];
           
             for(NSString *message in arrMessages){
                
                 [xmppManager receiveMessageForRoom:message];
             }
             
           
             
             
             // DO YOUR WORK HERE
             
         }
         else if ([data length] == 0 && error == nil)
         {
             //  NSLog(@"Nothing was downloaded.");
         }
         else if (error != nil){
             //  DDLogInfo(@"Error = %@", error);
         }
         
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

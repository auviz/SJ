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
       [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ERROR_SET_HISTORY_OPTION_ON_SERVER  object:self];
         }
         
     }];
    
    //[room changeRoomSubject:newRoomName];
    
}

@end

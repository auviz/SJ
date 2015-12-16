//
//  groupChatManager.m
//  SafeJab
//
//  Created by Самсонов Александр on 20.07.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import "groupChatManager.h"
#import "OTRAccountsManager.h"
#import "SetGlobVar.h"
#import "OTRProtocolManager.h"
#import "OTRLog.h"
#import "OTRRoom.h"
#import "Strings.h"



@implementation groupChatManager

@synthesize roomsWithFriends;
@synthesize linkToOTRComposeViewController;
@synthesize needDestroyRoomWithId;
@synthesize needLeaveRoomWithId;
@synthesize roomIDForLink;
@synthesize linkToGroupChatManager;

static NSMutableDictionary *sharedroomsWithFriends_ = nil;

static BOOL isRequestError_ = YES;


- (id)init
{

    
    self = [super init];
    if (self) {
        
         NSArray *accounts = [OTRAccountsManager allAccountsAbleToAddBuddies];
        
        
        for(OTRAccount *acc in accounts){
            
            
            if(SafeJabTypeIsEqual(acc.username, JABBER_HOST)){
             //Ищем аккаунт SJ
                _SJAccount = acc;
                
            }
            
        }
        
        self.needDestroyRoomWithId = nil;
        self.isFinishLoading = NO;
        isRequestError_ = YES;
        
        return self;
    }
}

-(NSURLConnection *)getConnection {
    return _curConnection;
}

-(void)deleteSharedRoomByID:(NSString *)roomID{
    if(!sharedroomsWithFriends_) return;
    [sharedroomsWithFriends_ removeObjectForKey:roomID];
}

+ (NSMutableDictionary *) sharedRoomsWithFriends
{
    if (sharedroomsWithFriends_)
    {
        return sharedroomsWithFriends_;
    }
    
    return nil;
    
}

+(BOOL)sharedIsRequestError{
    return isRequestError_;
    
}

-(void)sendByeForRoomID:(NSString*)RoomId{
     OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:_SJAccount];
    [xmppManager sendBye:_SJAccount.username roomID:RoomId];
}

-(void)sendRenameRoomForRoomID:(NSString*)RoomId{
    OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:_SJAccount];
    [xmppManager sendRenameRoom:_SJAccount.username roomID:RoomId];
}

-(void)deleteRoomByRoomId:(NSString*)RoomId
{
    
     DDLogInfo(@"deleteRoomByRoomId %@", RoomId);
    if(!_SJAccount) return;
    
    
     OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:_SJAccount];
    
   XMPPRoom *room =  [xmppManager getSJRooms:RoomId];
    
    
    [xmppManager deleteXmppRoom:room];
    
    [self deleteSharedRoomByID:RoomId];
  

}

-(void)addUserForRoomID:(NSString*)roomID accountUsername:(NSString *)addFriend{
    
    NSString *post =  [NSString stringWithFormat:@"accountUsername=%@&roomID=%@&addFriend=%@", _SJAccount.username, roomID, addFriend];
    // NSString *post = @"name=val1&photo=val2";
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:@"https://safejab.com/groupChat/addFriend.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //application/x-www-form-urlencoded multipart/form-data
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
             
             [self parseData:data];
             
             isRequestError_ = NO;
             
             OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:_SJAccount];
             [xmppManager sendInvite:addFriend roomID:roomID];
             [xmppManager sendImAddFriend:addFriend roomID:roomID];
             
             
             /*
              groupChatManager *GCM = [[groupChatManager alloc] init];
              [GCM getListsGroupChatWithUsername:update];
              */
             // DO YOUR WORK HERE
             
         }
         else if ([data length] == 0 && error == nil)
         {
             //  NSLog(@"Nothing was downloaded.");
         }
         else if (error != nil){
             
             isRequestError_ = YES;
             DDLogInfo(@"Error = %@", error);
         }
         
     }];
    
}

-(void)deleteUserForRoomID:(NSString*)roomID accountUsername:(NSString *)deleteFriend {

    
    
    
    NSString *post =  [NSString stringWithFormat:@"accountUsername=%@&roomID=%@&deleteFriend=%@", _SJAccount.username, roomID, deleteFriend];
    // NSString *post = @"name=val1&photo=val2";
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:@"https://safejab.com/groupChat/exitFromRoom.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //application/x-www-form-urlencoded multipart/form-data
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
             
             [self parseData:data];
             
             isRequestError_ = NO;
             
             OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:_SJAccount];
             [xmppManager sendBye:deleteFriend roomID:roomID];
             
             
              /*
                   groupChatManager *GCM = [[groupChatManager alloc] init];
                   [GCM getListsGroupChatWithUsername:update];
             */
             // DO YOUR WORK HERE
             
         }
         else if ([data length] == 0 && error == nil)
         {
             //  NSLog(@"Nothing was downloaded.");
         }
         else if (error != nil){
             
             isRequestError_ = YES;
             DDLogInfo(@"Error = %@", error);
         }
         
     }];
          
   
    
}


-(void)renameRoomById:(NSString*)RoomId newRoomName:(NSString *)newRoomName {
    
    DDLogInfo(@"renameRoomById %@", RoomId);
    
 
    NSString *post =  [NSString stringWithFormat:@"roomID=%@&roomName=%@", RoomId, newRoomName];
 
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:@"https://safejab.com/groupChat/chRoomName.php"]];
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
             DDLogInfo(@"Error = %@", error);
         }
         
     }];
    
    //[room changeRoomSubject:newRoomName];
    
}




-(void)leaveRoomById:(NSString*)RoomId {
    
    DDLogInfo(@"leaveRoomById %@", RoomId);
    
    OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:_SJAccount];
    XMPPRoom *room =  [xmppManager getSJRooms:RoomId];
    [room leaveRoom];
    [xmppManager deleteSJRoomFromDic:room];
    [self deleteSharedRoomByID:RoomId];
    [xmppManager deleteSJRoomFromDic:room];
    
}


+(NSString *)genUnicNameForChatRoom{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    return uuid;
}

- (void)createListOfFriendsForChatRoom:(NSArray *)arrFriendsInGroup roomID:(NSString *)roomID {
    
    NSString * strRowAccounts = [arrFriendsInGroup componentsJoinedByString:@"|"];
    
    
    strRowAccounts = [NSString stringWithFormat:@"%@|%@", _SJAccount.username, strRowAccounts]; //Ну кто у нас первый тот модератор
    
    self.typeQuery = createList;
    
 // NSString * unicNameChatRoom =[groupChatManager genUnicNameForChatRoom];
    
    // self = [super init];
    
    //  if (!self) {
    //     return nil;
    //  }
    
    
    // NSURL *url = [NSURL URLWithString:@"https://mail.lc-rus.com/install/getVersionApp.php"];
    // Create the request.
    // NSURLRequest *request = [NSURLRequest requestWithURL: url];
    
    // Create url connection and fire request
    //
    //  UIImage *photo = [UIImage imageNamed:@"photoTest.jpg"];
    
    NSString *post =  [NSString stringWithFormat:@"unicNameChatRoom=%@&strRowAccounts=%@", roomID, strRowAccounts];
    // NSString *post = @"name=val1&photo=val2";
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:@"https://safejab.com/groupChat/createGC.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //application/x-www-form-urlencoded multipart/form-data
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    _curConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self ];
    
    
    // return self;
}




-(void)deleteOrLeaveTheRoom:(NSString*)roomID {
    
    self.typeQuery = deleteOrLeaveTheRoom;
    
    NSString *post =  [NSString stringWithFormat:@"accountUsername=%@&roomID=%@", _SJAccount.username, roomID];
    // NSString *post = @"name=val1&photo=val2";
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:@"https://safejab.com/groupChat/exitFromRoom.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //application/x-www-form-urlencoded multipart/form-data
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    _curConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self ];
    
    
}


-(NSMutableURLRequest *)requestUpdateList {
    
    NSString *post =  [NSString stringWithFormat:@"accountUsername=%@", _SJAccount.username];
    // NSString *post = @"name=val1&photo=val2";
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:@"https://safejab.com/groupChat/getGC.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //application/x-www-form-urlencoded multipart/form-data
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    return request;
    
}




-(void)getListsGroupChatWithUsername: (queryType) typeQuery {
    
    if(!_SJAccount) return;
    
    self.typeQuery = typeQuery;
    
    NSMutableURLRequest *request = [self requestUpdateList];
    
    
    _curConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self ];


}






-(void)updateListSync {
    
    if(!_SJAccount) return;
    
       NSError *returnError = nil;
    
     NSHTTPURLResponse *response = NULL;
     NSMutableURLRequest *request = [self requestUpdateList];
    
   NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&returnError];
    
    if(returnError) isRequestError_ = YES; else isRequestError_ = NO;
        

    
    [self parseData:data];
   }


-(void)createGroupChatWidhFriends : (NSArray *) arrFriendsInGroup {
    
    

   
  //  NSArray *accounts = [OTRAccountsManager allAccountsAbleToAddBuddies];
  //  OTRAccount *account = [accounts firstObject];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
    OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:_SJAccount];
    xmppManager.arrFriendsInGroup = arrFriendsInGroup;
    

    
    
   // [NSString stringWithFormat:@"%@|%@", _SJAccount.username, strRowAccounts]
    
    //[self.roomsWithFriends setObject:arrFriendsInGroup forKey:[room arrFriendsInGroup]];
    
    xmppManager.linkToOTRComposeViewController = self.linkToOTRComposeViewController;
    
    NSString * roomID = [groupChatManager genUnicNameForChatRoom];
    
    NSMutableArray * tempArr = [[NSMutableArray alloc] init];
    
     [tempArr setObject:roomID atIndexedSubscript:0];
    [tempArr setObject:_SJAccount.username atIndexedSubscript:1];
    
    int i =2;
    
    for(NSString *friend in arrFriendsInGroup){
        [tempArr setObject:friend atIndexedSubscript:i];
        i++;
    }
    
    if(!sharedroomsWithFriends_) sharedroomsWithFriends_ = [[NSMutableDictionary alloc] init];

    [sharedroomsWithFriends_ setObject:tempArr forKey:roomID];
    
    [xmppManager createChatRoom:roomID];
    
    });
    
    
    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear its
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}


-(void)parseData:(NSData *)data{
    

    
    NSString *groupListStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.roomsWithFriends = [[NSMutableDictionary alloc] init];
    
    BOOL isNotRooms = [groupListStr isEqualToString:@"empty"];
    
    
    if(isNotRooms){
       
        self.roomsWithFriends = nil;
        sharedroomsWithFriends_ = nil;
        
      
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_ROOM_LIST object:self];
       
   
        
        
    } else {
    
        NSArray *listRooms = [[NSArray alloc] init];
        NSArray *room;
        
        listRooms =  [groupListStr componentsSeparatedByString:@"#"]; //Получаем комнаты
        
        
        for(NSString *row in listRooms){
            
            
            room = [row componentsSeparatedByString:@"|"]; //Получаем все остальное
            
            [self.roomsWithFriends setObject:room forKey:[room firstObject]]; //Room roomid|adminRoom|friends|...
            
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_ROOM_LIST object:self];
    }
    
    
    if(self.roomsWithFriends){
        
        sharedroomsWithFriends_ = self.roomsWithFriends;
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
   // if(self.typeQuery == createList) return ; //Если создание то нам пока насрать на ответ
    isRequestError_ = NO;
    
 
    
    [self parseData:_responseData];
    
    
    if(self.typeQuery == update){
        //Если обновился лист комнат то послать уведомление
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_ROOM_LIST object:self];
        
        [self didReceiveInvite];
        
        
    }else if(self.typeQuery == deleteOrLeaveTheRoom && self.needDestroyRoomWithId){ //Если удаление комнаты
       
 
        
        [self deleteRoomByRoomId:self.needDestroyRoomWithId];
        self.needDestroyRoomWithId = nil;
        
        
    } else if (self.typeQuery == deleteOrLeaveTheRoom && self.needLeaveRoomWithId){ //Если выходим из комнаты
        
        [self leaveRoomById:self.needLeaveRoomWithId];
        self.needLeaveRoomWithId = nil;
        
    }  else if(self.typeQuery == getAndJoin){
        
        [self joinAllRooms];
        
         //   [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_ROOM_LIST object:self];
        
  
        
       //  NSLog(@"EEEE %@", self.roomsWithFriends);
        
    }

    self.isFinishLoading = YES;
    
}

-(void)didReceiveInvite {
    
    if(self.linkToGroupChatManager && self.roomIDForLink){
        
        
        OTRRoom * room = [OTRRoom roomById:self.roomIDForLink];
        
        
        if(room.countInRoom != 0){ //Если комнаты не существует то не отправляем приглашение
            [self.linkToGroupChatManager createChatRoom:self.roomIDForLink]; //Не создаю просто подключаюсь к существующей
        }
        
    }
    
  //  self.linkToGroupChatManager = nil;
   // self.roomIDForLink = nil;
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    DDLogInfo(@"didFailWithError %@", error);
    
    isRequestError_ = YES;
    self.roomsWithFriends = nil;
}


+ (void)willJoinAllRooms
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //Вот тут я наконец присоединяю комнаты к чату
    groupChatManager * GCM = [[groupChatManager alloc] init];
        
       // [GCM updateListSync];
        
    
        [GCM getListsGroupChatWithUsername:getAndJoin];
    });

}

+(void)updateRoomsWithFriends {
  
    dispatch_async(dispatch_get_main_queue(), ^{
        //Тут я просто обновляю словарь комнат sharedroomsWithFriends_
        groupChatManager * GCM = [[groupChatManager alloc] init];
        
        [GCM getListsGroupChatWithUsername:update];
    });
    
}

+(void)showAlertGroupChat:(id)view{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Error Group Chat"
                                  message:@"Rooms are disabled... Please reload the application!"
                                  preferredStyle:UIAlertControllerStyleAlert];
    

    UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:OK_STRING
                             style:UIAlertActionStyleDefault
                             handler:nil];
    
    
    [alert addAction:ok];
    
    [view presentViewController:alert animated:YES completion:nil];
    
    
}


-(void)joinAllRooms{
    
    
            OTRXMPPManager *xmppManager = (OTRXMPPManager *)[[OTRProtocolManager sharedInstance] protocolForAccount:_SJAccount];
        
        
           // [xmppManager createChatRoom:@"group"]; //First room
    
    
    if(self.roomsWithFriends.count >= 1 ){
           
        
        for(NSString *key in self.roomsWithFriends){
            
            
           NSString *roomId = key;
            
            if(roomId.length == 0) return; //Если нет списка проигнорировать
            
        //Если уже в комнате не надо присоединятся
            
            
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [xmppManager createChatRoom:roomId]; //Соединяемся с коинатой не создаем!
        
        });
            
            
            
            
            
        }
        
        
    }
    
    
   
    
    
}



@end

//
//  OTRRoom.m
//  SafeJab
//
//  Created by Самсонов Александр on 22.07.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import "OTRRoom.h"
#import "OTRDatabaseManager.h"
#import "SetGlobVar.h"
#import "OTRProtocolManager.h"
#import "Strings.h"

@implementation OTRRoom

@synthesize rooms;

static NSDictionary *sharedRoomsFromDb_ = nil;


-(id)init {
    
    if(self = [super init]){
        
        
       NSDictionary * sharedRooms = [self getSharedRoomsFromDB];
        
        NSDictionary * roomsFromServer = [groupChatManager sharedRoomsWithFriends];

        
        if(!sharedRooms && !roomsFromServer) return self; //Первое условие (1)
        
        
        if([roomsFromServer isEqual:sharedRooms] && sharedRooms && roomsFromServer) {
            
            self.rooms = [[NSDictionary alloc] initWithDictionary: sharedRooms];
            
            return self; //(4)
        }
        
        
        if(!sharedRooms && roomsFromServer) {
            
            self.rooms = [[NSDictionary alloc] initWithDictionary:roomsFromServer];
            
            [self setRooms];
            
            return self; //Второе условие (2)
        }
        
        
        if(sharedRooms && !roomsFromServer) {
           
            self.rooms = [[NSDictionary alloc] initWithDictionary:sharedRooms];
            
            return self; //Третье условие (3)
        
        }
        
        
        if(![roomsFromServer isEqual:sharedRooms] && sharedRooms && roomsFromServer) {
            
            self.rooms = [[NSDictionary alloc] initWithDictionary: roomsFromServer];
            
            [self setRooms];
            
            return self; //(5)
        }
        
        
        
        
       // self.rooms = [[NSDictionary alloc] initWithDictionary:[groupChatManager sharedRoomsWithFriends]];
        
        if(self.rooms.count >=1){
            
        }
        
        return self;
        
    }
    
    return nil;
    
}


+ (OTRRoom *) roomById: (NSString* )roomId
{
    
    if(!roomId) return nil;
    
     OTRRoom *tempRoom = [[OTRRoom alloc] init];
    
    
    NSArray *strArr = [roomId componentsSeparatedByString:@"@"];
    
    if(strArr.count >= 2){
        
        roomId = [strArr firstObject];
    }
    
    
    NSArray *room =  [tempRoom.rooms objectForKey:roomId];
    
    
    if(room){
        
     tempRoom.roomId  = [room objectAtIndex:0];
     tempRoom.roomAdmin  = [room objectAtIndex:1];
     tempRoom.participants = [room subarrayWithRange:NSMakeRange(1, (room.count -2))];
     tempRoom.countInRoom = (NSInteger *)tempRoom.participants.count;
     tempRoom.nameRoom = [room lastObject];
        
  
        
    };
    
   // if([roomId isEqualToString:@"group"]){
   //     tempRoom.roomId = @"group";
   // }
    

    
      return tempRoom;
    
}


+(BOOL)isRoomInServer:(NSString *)roomID{
    
    NSArray *strArr = [roomID componentsSeparatedByString:@"@"];
    
    if(strArr.count >= 2){
        
        roomID = [strArr firstObject];
    }
    
    
    //Работает только после уведомлений из груп чата
    NSDictionary * roomsFromServer = [groupChatManager sharedRoomsWithFriends];
    
    NSArray *room =  [roomsFromServer objectForKey:roomID];
    
    if(room.count >0){
        return YES;
    }
    
    return NO;

}




-(NSString *)roomName {
    
    if([self.roomId isEqualToString:@"group"]) return @"Chat for everyone";
    
    if(self.countInRoom == 0) return nil;
    
    
    if(self.nameRoom.length > 0) return self.nameRoom;
    
    
    return [NSString stringWithFormat:@"%@ %d", RECIPIENTS, (int)self.countInRoom];
}


-(void)setRooms
{
    
    //  if(pin == nil) pin = @"";
     dispatch_async(dispatch_get_main_queue(), ^{
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        
        [transaction setObject:self.rooms forKey:@"rooms" inCollection:@"roomsCollection"];
    }];
         
     });
    
}

-(NSDictionary *)getSharedRoomsFromDB{
    
    if(!sharedRoomsFromDb_){
       
        sharedRoomsFromDb_ = [[NSDictionary alloc] initWithDictionary:[self getRoomsFromDb]];
        return sharedRoomsFromDb_;
        
    } else return sharedRoomsFromDb_;
}


-(NSDictionary *)getRoomsFromDb {
    
    __block NSDictionary *roomsDb = nil;
    
    [[OTRDatabaseManager sharedInstance].readWriteDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        roomsDb = [transaction objectForKey:@"rooms" inCollection:@"roomsCollection"];
    }];
    
    if(roomsDb.count >= 1) {
        return roomsDb;
    } else {
        return nil;
    }
    
}

/*
+(void)removeEmptyRoomsByRoomId:(NSString *)roomID{
    
    if([groupChatManager sharedIsRequestError]) return ;
    
    NSString * username = [NSString stringWithFormat:@"%@@%@", roomID, MUC_JABBER_HOST];
    OTRAccount *acc = SJAccount();
    
    
    
    
    __block OTRBuddy *buddy = nil;
    [[OTRDatabaseManager sharedInstance].mainThreadReadOnlyDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        buddy = [OTRBuddy fetchBuddyWithUsername:username withAccountUniqueId:acc.uniqueId transaction:transaction];
    }];
    
    if(!buddy) return;
    
    [[[OTRProtocolManager sharedInstance] protocolForAccount:acc] removeBuddies:@[buddy]];
    


}
*/


@end

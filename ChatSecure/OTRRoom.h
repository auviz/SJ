//
//  OTRRoom.h
//  SafeJab
//
//  Created by Самсонов Александр on 22.07.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "groupChatManager.h"


@interface OTRRoom : NSObject

@property NSInteger *countInRoom;
@property NSString *roomId;
@property NSString *roomAdmin;
@property NSArray *participants;
@property NSString *nameRoom;



@property NSDictionary *rooms;


+ (OTRRoom *) roomById: (NSString* )roomId;
-(NSString *)roomName;
+(BOOL)isRoomInServer:(NSString *)roomID;
//+(void)removeEmptyRoomsByRoomId:(NSString *)roomID;

@end

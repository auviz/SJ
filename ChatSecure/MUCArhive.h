//
//  MUCArhive.h
//  SafeJab
//
//  Created by Самсонов Александр on 11.12.15.
//  Copyright © 2015 Leader Consult. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPMessage.h"

@interface MUCArhive : NSObject

+(void)saveRoomMessage:(NSString*)RoomId message:(XMPPMessage *)message from:(NSString *)from;

+(void)getRoomMessages:(NSString *)roomID toAccount:(NSString *)toAccount;

+(NSString *)timeStamp;

@end

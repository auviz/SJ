//
//  groupChatManager.h
//  SafeJab
//
//  Created by Самсонов Александр on 20.07.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import "OTRXMPPManager.h"
#import "OTRAccount.h"


typedef NS_ENUM(NSUInteger, queryType) {
    createList,
    getAndJoin,
    update,
    deleteOrLeaveTheRoom
};
@class OTRComposeViewController;


@interface groupChatManager : OTRXMPPManager<NSURLConnectionDelegate> {
    
    OTRAccount * _SJAccount;
    NSMutableData * _responseData;
    NSURLConnection  * _curConnection;
  

}

@property queryType typeQuery;
@property BOOL isFinishLoading;
@property NSString *needDestroyRoomWithId;
@property NSString *needLeaveRoomWithId;
@property NSString *roomIDForLink;

+(BOOL)sharedIsRequestError;

+ (NSMutableDictionary *) sharedRoomsWithFriends;

-(void)createGroupChatWidhFriends : (NSArray *) arrFriendsInGroup;

- (void)createListOfFriendsForChatRoom:(NSArray *)arrFriendsInGroup roomID:(NSString *)roomID;

-(void)getListsGroupChatWithUsername: (queryType) typeQuery;

-(void)updateListSync;


-(void)joinAllRooms;

+ (void)willJoinAllRooms;

+(void)updateRoomsWithFriends;

-(NSURLConnection *)getConnection;

-(void)deleteRoomByRoomId:(NSString*)RoomId;

-(void)leaveRoomById:(NSString*)RoomId;

-(void)deleteOrLeaveTheRoom:(NSString*)roomID;
-(void)sendByeForRoomID:(NSString*)RoomId;
-(void)sendRenameRoomForRoomID:(NSString*)RoomId;


-(void)renameRoomById:(NSString*)RoomId newRoomName:(NSString *)newRoomName;
-(void)deleteUserForRoomID:(NSString*)roomID accountUsername:(NSString *)accountUsername;
-(void)addUserForRoomID:(NSString*)roomID accountUsername:(NSString *)addFriend;
+(void)showAlertGroupChat:(id)view;


@property (nonatomic, strong) NSMutableDictionary *roomsWithFriends;

@property OTRComposeViewController* linkToOTRComposeViewController;
@property OTRXMPPManager *linkToGroupChatManager;


@end

//
//  SetGlobVar.h
//  SafeJab
//
//  Created by Самсонов Александр on 16.01.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTRAccountsManager.h"
#import "OTRAccount.h"



@interface SetGlobVar : NSObject {
    SetGlobVar *GlobVar;
  // #define NSString *testDev;
   // static NSString *weradfd;
}

@property (strong) NSString *deviceTokenString;
//@property (strong) NSString *testDev;

+(void)SetConst: (NSString *)val;
+(NSString *)GetConst;


//zigzagcorp color
+ (UIColor *)messageBubbleZigGreenColor;

+ (UIColor *)SecurNameBuddyColor;

+ (UIColor *)messageBubbleWhiteColor;
    

+ (UIColor *)messageBackgroundGreyColor;





@end

extern NSString *const JABBER_HOST;
extern NSString *const MUC_JABBER_HOST;
extern NSString *const SECUR_HOST;
extern NSString *const MARK_PHOTO;
extern NSString *const MINI_PHOTO;
extern NSString *const MARK_LOCATION;
extern NSString *const MUC_MESSAGES_SEPARATOR;
extern NSString *const USER_FOR_NOTIF;
extern NSString *const USER_FOR_NOTIF_UPDATE_ROOM_LIST;

extern NSString *const XMLMS_PROTOCOL_MUC_USER;
extern NSString *const NOTIFICATION_UPDATE_ROOM_LIST;
extern NSString *const NOTIFICATION_NEED_RELOAD_COLLECTION;
extern NSString *const NOTIFICATION_DID_UPDATE_LOCATION;
extern NSString *const NOTIFICATION_DID_ERROR_GROUP_CHAT;
extern NSString *const NOTIFICATION_XMPP_STREAM_DID_DISCONNECT;
extern NSString *const NOTIFICATION_ADD_MUC_FRIEND;
extern NSString *const NOTIFICATION_I_GET_MY_VCARD;
extern NSString *const NOTIFICATION_DID_UPDATE_VCARD_FROM_SERVER;
extern NSString *const NOTIFICATION_ERROR_UPDATE_VCARD_FROM_SERVER;
extern NSString *const NOTIFICATION_DID_HISTORY_OPTION_ON_SERVER;
extern NSString *const NOTIFICATION_ERROR_SET_HISTORY_OPTION_ON_SERVER;

BOOL *SafeJabTypeIsEqual();

BOOL *isMarkPhoto(NSString *message);
BOOL *isMarkLocation(NSString *message);


void setDeviceTokenString();
NSString *getDeviceTokenString();

void setChangePin(BOOL *val);
BOOL *getChangePin();

void setzzzTest(NSString *val);
NSString *getzzzTest();

OTRAccount * SJAccount();

UIImage* resizedImage(UIImage *inImage, CGRect thumbRect);

NSString *dateToStringWithMask(NSDate *date, NSString *mask);

void deletePhotosWithPreview(NSString *unicName);

UIImage * imageWithView(UIView *view);

BOOL isConnectedSJAccount();

void clearSJAccount();

UIColor * stringToColor(NSString * string);

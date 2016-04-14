//
//  SetGlobVar.m
//  SafeJab
//
//  Created by Самсонов Александр on 16.01.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//  UI_USER_INTERFACE_IDIOM()
//

#import "SetGlobVar.h"
#import "OTRProtocolManager.h"

@implementation SetGlobVar

+(void)SetConst: (NSString *)val{
  //NSString *testDev = val;
    
    //static let testDev = val;
}

+(NSString *)GetConst{
    //return NSString *testDev;
}


//zigzagcorp color
+ (UIColor *)messageBubbleZigGreenColor
{
    return [UIColor colorWithRed:0.886f green:1.0f blue:0.78f alpha:1.0];
    
}

+ (UIColor *)SecurNameBuddyColor
{
    return [UIColor colorWithRed:0.1f green:0.1f blue:0.5f alpha:1.0];
}

//zigzagcorp color
+ (UIColor *)messageBubbleWhiteColor
{
    return [UIColor whiteColor];
    
}

//zigzagcorp color
+ (UIColor *)messageBackgroundGreyColor {
    return [UIColor colorWithRed:0.827f green:0.862f blue:0.89f alpha:1.0];
}

@end

NSString *const JABBER_HOST = @"safejab.com"; //Мой джаббер сервер
NSString *const MUC_JABBER_HOST = @"conference.safejab.com"; //Сервер для группового чата
NSString *const SECUR_HOST = @"jab4all.com"; //Мой джаббер сервер
NSString *const MARK_PHOTO =@"pHoToZUM_"; //Отметка фотографии
NSString *const MARK_LOCATION = @"zEfdaTov_"; //Отметка локации
NSString *const MINI_PHOTO =@"_mini"; //Отметка фотографии
NSString *const MUC_MESSAGES_SEPARATOR =@"<ZIG@MUC>"; //Для разделения групповых сообщений
NSString *const USER_FOR_NOTIF = @"notificationmanager";
NSString *const USER_FOR_NOTIF_UPDATE_ROOM_LIST = @"notificationmanagerUpdateRoomList";


NSString *const XMLMS_PROTOCOL_MUC_USER =@"http://jabber.org/protocol/muc#user"; //Протокол для XMPP room

NSString *const NOTIFICATION_UPDATE_ROOM_LIST= @"updateRoomList";

NSString *const NOTIFICATION_NEED_RELOAD_COLLECTION= @"NOTIFICATION_NEED_RELOAD_COLLECTION";

NSString *const NOTIFICATION_DID_UPDATE_LOCATION = @"didUpdateLocation";

NSString *const NOTIFICATION_DID_ERROR_GROUP_CHAT = @"NOTIFICATION_DID_ERROR_GROUP_CHAT";

NSString *const NOTIFICATION_XMPP_STREAM_DID_DISCONNECT = @"NOTIFICATION_XMPP_STREAM_DID_DISCONNECT";

NSString *const NOTIFICATION_ADD_MUC_FRIEND = @"NOTIFICATION_ADD_MUC_FRIEND";

NSString *const NOTIFICATION_I_GET_MY_VCARD = @"NOTIFICATION_I_GET_MY_VCARD";

NSString *const NOTIFICATION_DID_UPDATE_VCARD_FROM_SERVER = @"NOTIFICATION_DID_UPDATE_VCARD_FROM_SERVER";

NSString *const NOTIFICATION_ERROR_UPDATE_VCARD_FROM_SERVER = @"NOTIFICATION_ERROR_UPDATE_VCARD_FROM_SERVER";


NSString *const NOTIFICATION_DID_HISTORY_OPTION_ON_SERVER=@"NOTIFICATION_DID_SET_HISTORY_OPTION_ON_SERVER";
NSString *const NOTIFICATION_ERROR_SET_HISTORY_OPTION_ON_SERVER=@"NOTIFICATION_ERROR_SET_HISTORY_OPTION_ON_SERVER";



static NSString *deviceTokenString;

void setDeviceTokenString(NSString *val){
    
    deviceTokenString= val;
    
}

NSString *getDeviceTokenString(){
    
  return  deviceTokenString;
    
   // return DevTest;
}


///

static NSString *zzzTest;

void setzzzTest(NSString *val){
    
    zzzTest= val;
    
}

NSString *getzzzTest(){
    
    return  zzzTest;
    
    // return DevTest;
}

BOOL *SafeJabTypeIsEqual(NSString *curAcc,  NSString *withHost){
    

    NSRange range_safeJab = [curAcc rangeOfString:withHost];
 
   // DDLogInfo(@"RANGE %d",range_safeJab.length);
    
    if(range_safeJab.length >0){
        return YES;
        
    } else {
        return NO;
    }
    
   
}



static BOOL *isChangePin;

void setChangePin(BOOL *val){
    
    isChangePin= val;
    
}

BOOL *getChangePin(){
    
    return  isChangePin;
    
    // return DevTest;
}

BOOL *isMarkPhoto(NSString *message){
    
    if([message length] < 9) return NO;
        
        if([[message substringToIndex:9] isEqualToString:MARK_PHOTO]){
        
            return YES;
        }
    
    return NO;
    
}

BOOL *isMarkLocation(NSString *message){
    
    if([message length] < 9) return NO;
    
    if([[message substringToIndex:9] isEqualToString:MARK_LOCATION]){
        
        return YES;
    }
    
    return NO;
    
}

static OTRAccount * SJAccount_;

void clearSJAccount(){
    SJAccount_ = nil;
}

OTRAccount * SJAccount(){
    
    
    if(SJAccount_) return SJAccount_; //Если мы его получили то и хорошо вернуть
    
    
    NSArray *accounts = [OTRAccountsManager allAccountsAbleToAddBuddies];
    
    for(OTRAccount *acc in accounts){
        
        
        if(SafeJabTypeIsEqual(acc.username, JABBER_HOST)){
            //Ищем аккаунт SJ
            SJAccount_ = acc;
            
        }
        
    }
    return SJAccount_;
}

BOOL isConnectedSJAccount(){
    
    if(!SJAccount()) return NO;
    
  return [[OTRProtocolManager sharedInstance] isAccountConnected:SJAccount()];
}


NSString *dateToStringWithMask(NSDate *date, NSString *mask)
{
    
    //dd.MM.yyyy HH:mm
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:mask];
    return [formatter stringFromDate:date];
    
    
}

void deletePhotosWithPreview(NSString *unicName){
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
   
    NSString* miniPhotoPath = [documentsDirectory stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%@%@.jpg", unicName, MINI_PHOTO]];
    
    NSString* bigPhotoPath = [documentsDirectory stringByAppendingPathComponent:
                               [NSString stringWithFormat:@"%@.jpg", unicName]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    BOOL miniFileExists = [fileManager fileExistsAtPath:miniPhotoPath];
    
    BOOL bigFileExists = [fileManager fileExistsAtPath:bigPhotoPath];
    
    NSError *error;
    
    if(miniFileExists){
        
        BOOL success = [fileManager removeItemAtPath:miniPhotoPath error:&error];
        if (!success) NSLog(@"ErrorDelete: %@", [error localizedDescription]);
        
    }
    
    
    if(bigFileExists){
        
        
        BOOL success = [fileManager removeItemAtPath:bigPhotoPath error:&error];
        if (!success) NSLog(@"ErrorDelete: %@", [error localizedDescription]);
        
    }
  
}

UIImage * imageWithView(UIView *view)
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

UIColor * stringToColor(NSString * string) {
    NSString * zs = string;
    
    int xxx2 = 0;
    int xxx = 0;
    int maxRgb = 255;
    
    float newR = 0.7;
    float newG = 0.7;
    float newB = 0.7;
    
    if(zs.length >= 2){
        xxx = [zs characterAtIndex:0];
        xxx2 = [zs characterAtIndex:1];
    } else {
        xxx = [zs characterAtIndex:0];
    }
    
    int full = xxx + xxx2;
    
    newR = (full % 9);
    newG = (full % 5);
    newB = (full % 7);
    
    newR = (full*newR) /2;
    newG = (full*newG) /2;
    newB= (full*newB) /2;
    
    newR = newR > maxRgb ? maxRgb/newR : newR/maxRgb;
    newG = newG > maxRgb ? maxRgb/newG : newG/maxRgb;
    newB = newB > maxRgb ? maxRgb/newB : newB/maxRgb;
    
 //   if(newR < 0.3){
   //     newR = newR + 0.5;
   // } else
        
       // if(newR < 0.5) newR = newR + 0.3;
        
       // if(newG < 0.3){
      //      newG = newG + 0.5;
       // } else
         //   if(newG < 0.5) newG = newG + 0.3;
            
           // if(newB < 0.3){
           //     newB = newB + 0.5;
           // } else
                
             //   if(newB < 0.5) newB = newB + 0.3;
    
            UIColor * color =  [[UIColor alloc] initWithRed:newR green:newG blue:newB alpha:1];
                
                
                
              ///  NSLog(@"%f_%f_%f", newR, newG,  newB);
                

                return color;
}

/*
UIImage* resizedImage(UIImage *inImage, CGRect thumbRect)
{
    CGImageRef          imageRef = [inImage CGImage];
    CGImageAlphaInfo    alphaInfo = CGImageGetAlphaInfo(imageRef);
    
    // There's a wierdness with kCGImageAlphaNone and CGBitmapContextCreate
    // see Supported Pixel Formats in the Quartz 2D Programming Guide
    // Creating a Bitmap Graphics Context section
    // only RGB 8 bit images with alpha of kCGImageAlphaNoneSkipFirst, kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst,
    // and kCGImageAlphaPremultipliedLast, with a few other oddball image kinds are supported
    // The images on input here are likely to be png or jpeg files
    if (alphaInfo == kCGImageAlphaNone)
        alphaInfo = kCGImageAlphaNoneSkipLast;
    
    // Build a bitmap context that's the size of the thumbRect
    CGContextRef bitmap = CGBitmapContextCreate(
                                                NULL,
                                                thumbRect.size.width,       // width
                                                thumbRect.size.height,      // height
                                                CGImageGetBitsPerComponent(imageRef),   // really needs to always be 8
                                                4 * thumbRect.size.width,   // rowbytes
                                                CGImageGetColorSpace(imageRef),
                                                alphaInfo
                                                );
    
    // Draw into the context, this scales the image
    CGContextDrawImage(bitmap, thumbRect, imageRef);
    
    // Get an image from the context and a UIImage
    CGImageRef  ref = CGBitmapContextCreateImage(bitmap);
    UIImage*    result = [UIImage imageWithCGImage:ref scale:1 orientation:inImage.imageOrientation ];
    
    CGContextRelease(bitmap);   // ok if NULL
    CGImageRelease(ref);
    
    return result;
}
*/

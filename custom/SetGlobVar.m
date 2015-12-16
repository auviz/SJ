//
//  SetGlobVar.m
//  SafeJab
//
//  Created by Самсонов Александр on 16.01.15.
//  Copyright (c) 2015 Leader Consult. All rights reserved.
//  UI_USER_INTERFACE_IDIOM()
//

#import "SetGlobVar.h"

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



NSString *const XMLMS_PROTOCOL_MUC_USER =@"http://jabber.org/protocol/muc#user"; //Протокол для XMPP room

NSString *const NOTIFICATION_UPDATE_ROOM_LIST= @"updateRoomList";

NSString *const NOTIFICATION_NEED_RELOAD_COLLECTION= @"NOTIFICATION_NEED_RELOAD_COLLECTION";

NSString *const NOTIFICATION_DID_UPDATE_LOCATION = @"didUpdateLocation";

NSString *const NOTIFICATION_DID_ERROR_GROUP_CHAT = @"NOTIFICATION_DID_ERROR_GROUP_CHAT";

NSString *const NOTIFICATION_XMPP_STREAM_DID_DISCONNECT = @"NOTIFICATION_XMPP_STREAM_DID_DISCONNECT";

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

OTRAccount * SJAccount(){
    NSArray *accounts = [OTRAccountsManager allAccountsAbleToAddBuddies];
    OTRAccount * SJAccount = nil;
    
    for(OTRAccount *acc in accounts){
        
        
        if(SafeJabTypeIsEqual(acc.username, JABBER_HOST)){
            //Ищем аккаунт SJ
            SJAccount = acc;
            
        }
        
    }
    return SJAccount;
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

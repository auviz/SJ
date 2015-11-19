//
//  savePhoto.h
//  testPostPhoto
//
//  Created by Самсонов Александр on 09.04.15.
//  Copyright (c) 2015 LC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTRMessage.h"

@class OTRMessagesViewController;



@interface SavePhoto : NSObject<NSURLConnectionDelegate>
{
    NSMutableData *_responseData;
    
    NSString *_unicName;
    NSData *_imageData;
    OTRMessage *_message;
    
}



@property NSURLConnection  *curConnection;

@property (strong, nonatomic) id linkToMessagesViewController;


- (void)postToServer: (UIImage *) photo unicName:(NSString *) unicName;

+(NSString *)genUnicNameForPhoto;

+ (void)saveImage: (UIImage*)image unicName: (NSString *)unicName;

+(void)genMiniImage: (UIImage *)image unicName: (NSString *)unicName;

+(UIImage *)compressImage:(UIImage *)image maxSize: (int)maxSize;


@end
